#
# Cookbook Name:: cq
# Provider:: package
#
# Copyright (C) 2014 Jakub Wadolowski
#
# Licensed under the Apache License, Version 2.0 (the "License");
# you may not use this file except in compliance with the License.
# You may obtain a copy of the License at
#
#    http://www.apache.org/licenses/LICENSE-2.0
#
# Unless required by applicable law or agreed to in writing, software
# distributed under the License is distributed on an "AS IS" BASIS,
# WITHOUT WARRANTIES OR CONDITIONS OF ANY KIND, either express or implied.
# See the License for the specific language governing permissions and
# limitations under the License.
#

def whyrun_supported?
  true
end

# Calculates Authorization HTTP header value
#
# @return [String] encoded HTTP header value compliant with the standard
def auth_header_value
  Base64.encode64("#{new_resource.http_user}:#{new_resource.http_pass}")
end

# Validates source attribute of cq_package resource.
# To pass it has to be either valid HTTP/HTTP URI or an existing local path
#
# @return [URI] valid/parsed URI object
def validate_source
  begin
    src = URI.parse(new_resource.source)

    # Raise an error if source attr is empty
    if new_resource.source.empty?
      Chef::Application.fatal!("[CQ Package] Source attribute can't be empty!")
    end

    unless src.instance_of?(URI::HTTP) ||
           src.instance_of?(URI::HTTPS) ||
           src.instance_of?(URI::Generic)
      Chef::Application.fatal!("#{new_resource.source} is neither local path "\
                               '(generic URI) nor HTTP/HTTPS URI!')
    end

    local_path = Pathname.new(src.path)

    if src.instance_of?(URI::Generic) && !local_path.exist?
      Chef::Application.fatal!("#{new_resource.source} does not exist!")
    end

    if src.instance_of?(URI::Generic) && !local_path.file?
      Chef::Application.fatal!("#{new_resource.source} is not a file!")
    end
  rescue URI::InvalidURIError => e
    Chef::Application.fatal!("#{new_resource.source} is not a valid URI: #{e}")
  end

  src
end

# Returns destination directory used as CQ package cache.
# Fallback to standard Chef cache in case of not defined/empty/not existing
# directory definied by ['cq']['package_cache'] node attribute
#
# @return [Pathname] path to cq package cache
def package_cache
  if node['cq']['package_cache'].nil? || node['cq']['package_cache'].empty?
    Pathname.new(Chef::Config[:file_cache_path])
  else
    cache_dir = ''
    begin
      cache_dir = Pathname.new(node['cq']['package_cache'])
    rescue ArgumentError => e
      Chef::Application.fatal!("#{node['cq']['package_cache']} is not a "\
                               " valid path: #{e}")
    end
    if cache_dir.directory? && cache_dir.exist?
      cache_dir
    else
      Pathname.new(Chef::Config[:file_cache_path])
    end
  end
end

# Creates a remote_file resource with action set to nothing
#
# @return [Chef::Resource::RemoteFile]
def remote_file_resource
  @remote_file_resource ||= remote_file @dst_path do
    source new_resource.source
    owner node['cq']['user']
    group node['cq']['group']
    mode '0644'
    backup false
    action :nothing
  end
end

# Based on source attribute downloads CQ package from HTTP/HTTPS endpoints
# using built-in remote_file resource or just returns source attribute if
# it is a valid and existing local path
#
# @return [String] local path to CQ package
def package_path
  # Validate source attribute
  src = validate_source

  # Return source attribute if it's not a remote one or download otherwise
  if src.instance_of?(URI::Generic)
    new_resource.source
  else
    cache_dir = package_cache

    # Calculate file name from give URI
    file_name = Pathname.new(src.path).basename.to_s

    # Assembly and set absolute local path to CQ package
    @dst_path = (cache_dir + file_name).to_s

    # Add HTTP Authorization header if necessary
    unless new_resource.http_user.empty? &&
        new_resource.http_pass.empty?
      remote_file_resource.headers('Authorization' =>
                                  "Basic #{auth_header_value}")
    end

    # Add checksum validation if necessary
    unless new_resource.checksum.empty? || new_resource.checksum.nil?
      remote_file_resource.checksum = new_resource.checksum
    end

    # Run remote_file resource to download the CQ package
    remote_file_resource.run_action(:create)

    # Return path to downloaded file
    @dst_path
  end
end

# Get package list on a given CQ instance
#
# Output format:
# <packages>
#   <package>
#     <group>test_group</group>
#     <name>test_package</name>
#     ...
#   </package>
#   ...
# </packages>
#
# @return [REXML::Element] list of packages as an XML string
def package_list
  require 'rexml/document'

  # API pre-flight check
  pkg_mgr_guard

  # Get list of packages using CQ UNIX Toolkit
  cmd_str = "#{node['cq-unix-toolkit']['install_dir']}/cqls -x "\
            "-i #{new_resource.instance} "\
            "-u #{new_resource.username} "\
            "-p #{new_resource.password}"
  Chef::Log.debug('Listing packages present in CRX Package Manager')
  cmd = Mixlib::ShellOut.new(cmd_str)
  cmd.run_command
  Chef::Log.debug "package_list command: #{cmd_str}"
  Chef::Log.debug "package_list stdout: #{cmd.stdout}"
  Chef::Log.debug "package_list stderr: #{cmd.stderr}"
  begin
    cmd.error!
  rescue
    Chef::Application.fatal!("Cannot get package list: #{cmd.stderr}")
  end

  # Theoretically speaking cqls should never return empty string, hence no
  # validation here. Nevertheless I encoutered such issues some time in the
  # past and decided to implement a preflight check for that (pkg_mgr_guard).
  # Since it's there it never occurred again.

  # Extract and return <packages> element from original XML
  begin
    REXML::XPath.first(REXML::Document.new(cmd.stdout), '//packages')
  rescue => e
    Chef::Application.fatal!("Cannot parse XML returned by CQ instance: #{e}")
  end
end

# Looks for a package(s) on a given CQ instance
#
# @return [Array] an array of REXML::Element objects with package info
def package_search
  require 'rexml/document'

  packages = []

  # Iterate thorugh packages and get info about package you're looking for
  package_list.elements.each('package') do |pkg|
    packages.push(pkg) if package_attr_from_object(pkg, 'name') ==
      @metadata_name && package_attr_from_object(pkg, 'group') ==
      @metadata_group
  end

  packages
end

# Get information from CRX Package Manager about specific package
#
# @return [REXML::Element] XML with package information if package is present
# @return [nil] nil if there's no package that meets given constraints
def package_info
  package_search.each do |pkg|
    return pkg if package_attr_from_object(pkg, 'version') == @metadata_version
  end

  # Return nil if 0 packages meet name/group/version requirements
  nil
end

# Extract raw information from package metadata
#
# @param type [String] metadata type, accepted values: properties, filters
# @retrurn [REXML::Document] raw XML object
def package_metadata(type)
  require 'rexml/document'

  case type
  when 'properties'
    cmd_str = "#{node['cq-unix-toolkit']['install_dir']}/cqrepkg -P " +
      package_path
  when 'filters'
    cmd_str = "#{node['cq-unix-toolkit']['install_dir']}/cqrepkg -F " +
      package_path
  else
    Chef::Application.fatal!('Unsupported metadata type while extracting info'\
                            ' from CRX package! Accepted values: properties,'\
                            ' filters')
  end

  cmd = Mixlib::ShellOut.new(cmd_str)
  Chef::Log.debug "Extracting #{type} from CRX package"
  cmd.run_command
  Chef::Log.debug "package_metadata command: #{cmd_str}"
  Chef::Log.debug "package_metadata stdout: #{cmd.stdout}"
  Chef::Log.debug "package_metadata stderr: #{cmd.stderr}"
  begin
    cmd.error!
    Chef::Log.debug "Package #{type} successfully extracted"
  rescue
    Chef::Application.fatal!("Can't extract package #{type}: #{cmd.stderr}")
  end

  begin
    REXML::Document.new(cmd.stdout)
  rescue => e
    Chef::Application.fatal!("Cannot parse #{type} XML file: #{e}")
  end
end

# Gets package attribute from properties.xml
#
# @param attr_name [String] package attribute to look for
# @return [String] package attribute
def package_attr_from_metadata(attr_name)
  require 'rexml/document'

  begin
    # Return empty string in case of <entry key="attr_name"/> (.text == nil)
    value = REXML::XPath.first(package_metadata('properties'),
                               "//entry[@key='#{attr_name}']").text
    if value.nil?
      return ''
    else
      return value
    end
  rescue => e
    Chef::Application.fatal!("Cannot get package #{attr_name} from XML "\
                             "object: #{e}")
  end
end

# Gets package attribute from CRX package object
#
# @param pkg_xml [REXML::Element] package XML object
# @param attr_name [String] package attribute to look for
# @return [String] package attribute
def package_attr_from_object(pkg_xml, attr_name)
  require 'rexml/document'

  begin
    # Return empty string in case of <attr_name/> instead of
    # <attr_name></attr_name> (.text == nil)
    value = pkg_xml.elements[attr_name].text
    if value.nil?
      return ''
    else
      return value
    end
  rescue => e
    Chef::Application.fatal!("Cannot get package #{attr_name} from XML "\
                             "object: #{e}")
  end
end

# Sets uploaded attribute if package is uploaded to given instance
#
# @return [Boolean] true if package is already uploaded, false otherwise
def package_uploaded?
  if package_info.nil?
    return false
  else
    return true
  end
end

# Sets installed attribute if package is already installed
#
# @return [Boolean] true if package is already installed, false otherwise
def package_installed?
  # Package has to be uploaded first to be considered installed
  return false if @uploaded == false

  installed_pkgs = []

  # Collect packages with not empty lastUnpacked attribute
  package_search.each do |pkg|
    unless package_attr_from_object(pkg, 'lastUnpacked').empty?
      installed_pkgs.push(pkg)
    end
  end

  # The assumption is that lastUnpacked is always in a parsable format.
  # Since it's generated by CRX itself it's very unlikely that it might be
  # invalid. Nevertheless I decided to leave this note here in case of any
  # issues in the future.

  # 0 packages have been installed - return false
  return false if installed_pkgs.empty?

  # Make sure that all "lastUnpacked" dates are parsable and remove

  # Look for the package with the newest lastUnpacked element
  #
  # Consider first element in package array as the newest when:
  # - only single package is present
  # - more than one package is present, but we have to start the comparison
  #   process somehowe and compare installation dates against something
  newest_pkg = installed_pkgs.first

  # Iterate over installed packages using element pair as iterator
  installed_pkgs.each_cons(2) do |pkg1, pkg2|
    newest_pkg = pkg1
    if DateTime.parse(package_attr_from_object(pkg1, 'lastUnpacked')) <
      DateTime.parse(package_attr_from_object(pkg2, 'lastUnpacked'))
      newest_pkg = pkg2
    end
  end

  # Compare the version of new resource and already installed resource
  if @metadata_version == package_attr_from_object(newest_pkg, 'version')
    return true
  else
    return false
  end
end

# Sets downloaded attribute if package was already downloaded
#
# @return [Boolean] true if package was already downaloded, false otherwise
def package_downloaded?
  true
end

# "Guard" that allows for interaction with CRX Package Manager ONLY when it
# works properly. Extremely useful when package installation (i.e. hotfix)
# does some amendments in OSGi bundles state (i.e. restarts CRX Package
# Manager bundle and effectively makes it temporarily unavailable - it responds
# either with 500/404 or empty page).
#
# Example scenario:
#
# cq_packge X do
#   ...
#   action :install
# end
#
# <This is the place where bundle is restarted as an effect of package X
# installation>
#
# cq_package Y do
#   ...
#   action :install
# end
#
# Above ends with failure as package Y cannot be properly installed due to
# unavailability of CRX Package Manager.
#
# This method has to be invoked before any interaction with Package Manager.
#
# Successful criteria:
# 1) com.adobe.granite.crx-packagemgr bundle is Active
# 2) http://<INSTANCE>:<PORT>/crx/packmgr/service.jsp returns 200
#
# Both items are actively sampled every 10 seconds up to 60 checks (10
# minutes). As soon as first requirement is fulfilled 2nd check is verified
# with the same frequency. If any of them fails after 60 checks Chef run is
# aborted.

# 1st requirement: OSGi bundle is in Active state
def pkg_mgr_bundle_guard
  cmd_str = "#{node['cq-unix-toolkit']['install_dir']}/cqosgi -m "\
            "-i #{new_resource.instance} "\
            "-u #{new_resource.username} "\
            "-p #{new_resource.password} "\
            "| grep 'com.adobe.granite.crx-packagemgr' "\
            "| awk '{printf \"%s\", $3}'"

  Chef::Log.debug('Verifying CRX Package Manager bundle')

  # Max number of iterations. imax * 10 seconds = how long to wait for CRX
  # Package Manager
  i_max = 60

  (1..i_max).each do |i|
    cmd = Mixlib::ShellOut.new(cmd_str)
    cmd.run_command
    Chef::Log.debug "pkg_mgr_bundle_check #{i}/#{i_max} command: #{cmd_str}"
    Chef::Log.debug "pkg_mgr_bundle_check #{i}/#{i_max} stdout: #{cmd.stdout}"
    Chef::Log.debug "pkg_mgr_bundle_check #{i}/#{i_max} stderr: #{cmd.stderr}"

    begin
      cmd.error!
    rescue => e
      Chef::Log.error "Unable to verify CRX Package Manager OSGi bundle: #{e}"
    end

    break if cmd.stdout == 'Active'

    # Timeout verification
    if i < i_max
      sleep 10
    else
      Chef::Application.fatal!("Cannot proceed as CRX Package Manager bundle is
                                still in #{cmd.stdout} state.")
    end
  end
end

# 2nd requirement: CRX Package Manager API responds with 200
def pkg_mgr_api_guard
  cmd_str = "curl -s -o /dev/null -w '%{http_code}' "\
            "-u #{new_resource.username}:#{new_resource.password} "\
            "#{new_resource.instance}/crx/packmgr/service.jsp"

  Chef::Log.debug('Verifying CRX Package Manager API status code')

  # Max number of iterations. imax * 10 seconds = how long to wait for CRX
  # Package Manager
  i_max = 60

  (1..i_max).each do |i|
    cmd = Mixlib::ShellOut.new(cmd_str)
    cmd.run_command
    Chef::Log.debug "pkg_mgr_api_check #{i}/#{i_max} command: #{cmd_str}"
    Chef::Log.debug "pkg_mgr_api_check #{i}/#{i_max} stdout: #{cmd.stdout}"
    Chef::Log.debug "pkg_mgr_api_check #{i}/#{i_max} stderr: #{cmd.stderr}"

    begin
      cmd.error!
    rescue => e
      Chef::Log.error "Unable to verify CRX Package Manager API: #{e}"
    end

    break if cmd.stdout == '200'

    # Timeout verification
    if i < i_max
      sleep 10
    else
      Chef::Application.fatal!("Cannot proceed as CRX Package Manager still
                                responds with #{cmd.stdout} code.")
    end
  end
end

# Combined CRX Package Manager check
def pkg_mgr_guard
  Chef::Log.info('Waiting for CRX Package Manager...')
  pkg_mgr_bundle_guard
  pkg_mgr_api_guard
  Chef::Log.info('CRX Package Manager seems to be working fine. Moving on.')
end

# Loads current resource and all accessor attributes
def load_current_resource
  @current_resource = Chef::Resource::CqPackage.new(new_resource.name)

  # Load "state" attributes from new resource
  @current_resource.username(new_resource.username)
  @current_resource.password(new_resource.password)
  @current_resource.instance(new_resource.instance)

  # Set metadata properties
  @metadata_name = package_attr_from_metadata('name')
  @metadata_version = package_attr_from_metadata('version')
  @metadata_group = package_attr_from_metadata('group')

  # Set attribute acccessors
  @current_resource.uploaded = package_uploaded?
  @current_resource.installed = package_installed?

  # Set properties from CRX Package Manager (only possible when package is
  # uploaded)
  return unless @current_resource.uploaded
  @crx_name = package_attr_from_object(package_info, 'name')
  @crx_version = package_attr_from_object(package_info, 'version')
  @crx_group = package_attr_from_object(package_info, 'group')
  @crx_downloadname = package_attr_from_object(package_info, 'downloadName')
end

# Uploads package to a given CQ instance
def upload_package
  # API pre-flight check
  pkg_mgr_guard

  cmd_str = "#{node['cq-unix-toolkit']['install_dir']}/cqput "\
            "-i #{new_resource.instance} "\
            "-u #{new_resource.username} "\
            "-p #{new_resource.password} " +
            package_path
  cmd = Mixlib::ShellOut.new(cmd_str)
  Chef::Log.info "Uploading package #{new_resource.name}"
  cmd.run_command
  Chef::Log.debug "cq_package_upload command: #{cmd_str}"
  Chef::Log.debug "cq_package_upload stdout: #{cmd.stdout}"
  Chef::Log.debug "cq_package_upload stderr: #{cmd.stderr}"
  begin
    cmd.error!
    Chef::Log.info "Package #{new_resource.name} has been successfully "\
                   'uploaded'
  rescue
    Chef::Application.fatal!("Can't upload package #{new_resource.name}: " +
                             cmd.stderr)
  end
end

# Installs CQ package
#
# Since cqrun command (CQ UNIX Toolkit) does not support installation of
# specifc package version from the same group, a curl wrapper has been used
# instead.
#
# Stdout of curl command:
# <response_json>;<http_status>
#
# Example:
# {"success":false,"msg":"no package"};200
def install_package
  require 'json'

  # API pre-flight check
  pkg_mgr_guard

  cmd_str = "curl -s -X POST -w ';%{http_code}' "\
            "-u #{new_resource.username}:#{new_resource.password} "\
            "#{new_resource.instance}/crx/packmgr/service/.json/etc/packages"\
            "/#{@crx_group}/#{@crx_downloadname}?cmd=install"
  cmd = Mixlib::ShellOut.new(cmd_str)
  Chef::Log.info "Installing package #{new_resource.name}"
  cmd.run_command
  Chef::Log.debug "cq_package_install command: #{cmd_str}"
  Chef::Log.debug "cq_package_install stdout: #{cmd.stdout}"
  Chef::Log.debug "cq_package_install stderr: #{cmd.stderr}"
  begin
    cmd.error!
    Chef::Log.info "Package #{new_resource.name} has been successfully "\
                   'installed'
  rescue
    Chef::Application.fatal!("Can't install package #{new_resource.name}: " +
                             cmd.stderr)
  end

  # Split the output
  #
  # output[0] => JSON returned by CRX Package Manager API
  # output[1] => response code
  output = cmd.stdout.split(/;(?=[0-9]{3}$)/)

  # Parse HTTP response status code
  Chef::Application.fatal!('CRX Package Manager returned non-200 response '\
                          "code: #{output[1]}!") if output[1] != '200'

  # Parse JSON returned by API
  begin
    json_resp = JSON.parse(output[0])
  rescue => e
    Chef::Log.error("#{json_resp} is not a parsable JSON: #{e}")
  end

  Chef::Application.fatal!('Not successful package installation: ' +
                            output[0]) if json_resp['success'] != true
end

action :upload do
  if @current_resource.uploaded
    Chef::Log.info("Package #{new_resource.name} is already uploaded - "\
                   'nothing to do')
  else
    converge_by("Upload #{ new_resource }") do
      upload_package
    end
  end
end

action :install do
  if @current_resource.installed
    Chef::Log.info("Package #{new_resource.name} is already installed - "\
                   'nothing to do')
  else
    converge_by("Install #{ new_resource }") do
      install_package
    end
  end
end
