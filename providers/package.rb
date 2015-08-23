#
# Cookbook Name:: cq
# Provider:: package
#
# Copyright (C) 2015 Jakub Wadolowski
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
    begin
      remote_file_resource.run_action(:create)
    rescue => e
      Chef::Application.fatal!(
        "Can't download file from #{remote_file_resource.source}!\n"\
        "Error description: #{e}"
      )
    end

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

  # There's no need to call CQ every single time, as the output is not changing
  # during cq_package lifecycle (until some action, i.e. install/update, is
  # invoked, but after that there's no need to fetch any data from API).
  # All in all package list can be cached and reused on all subsequent calls
  # (except 1st)
  if @package_list.nil?
    # Get list of packages using CQ UNIX Toolkit
    cmd_str = "#{node['cq-unix-toolkit']['install_dir']}/cqls -x "\
              "-i #{new_resource.instance} "\
              "-u #{new_resource.username} "\
              "-p #{new_resource.password}"
    Chef::Log.debug('Listing packages present in CRX Package Manager')
    cmd = Mixlib::ShellOut.new(cmd_str, :timeout => 180)
    cmd.run_command

    begin
      cmd.error!
    rescue => e
      Chef::Application.fatal!("Cannot get package list!\n"\
                              "Error description: #{e}")
    end

    # Theoretically speaking cqls should never return empty string, so no
    # validation here. Nevertheless I encoutered such issues some time in the
    # past and decided to implement a preflight checks for that. Since it's
    # there problem never occurred again.

    # Extract and return <packages> element from original XML
    begin
      @package_list =
        REXML::XPath.first(REXML::Document.new(cmd.stdout), '//packages')
    rescue => e
      Chef::Application.fatal!("Cannot parse XML returned by CQ: #{e}")
    end
  end

  @package_list
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
# @retrurn [REXML::Document] raw XML object
def package_metadata
  require 'rexml/document'

  # Extract package properties from zip file and cache the output at instance
  # variable
  if @pkg_metadata.nil?
    cmd_str = "#{node['cq-unix-toolkit']['install_dir']}/cqrepkg -P " +
              package_path

    cmd = Mixlib::ShellOut.new(cmd_str)
    Chef::Log.debug 'Extracting properties from CQ package...'
    cmd.run_command

    begin
      cmd.error!
      Chef::Log.debug 'Package properties has been successfully extracted '\
                      'from metadata file.'
    rescue => e
      Chef::Application.fatal!(
        "Can't extract package properties from metadata"\
        " file!\nError description: #{e}"
      )
    end

    begin
      @pkg_metadata = REXML::Document.new(cmd.stdout)
    rescue => e
      Chef::Application.fatal!("Cannot parse properties XML file: #{e}")
    end
  end

  # Return package properties - either calculated (1st call) or cached (all
  # subsequent calls) output
  @pkg_metadata
end

# Gets package attribute from properties.xml
#
# @param attr_name [String] package attribute to look for
# @return [String] package attribute
def package_attr_from_metadata(attr_name)
  require 'rexml/document'

  begin
    # Return empty string in case of <entry key="attr_name"/> (.text == nil)
    value = REXML::XPath.first(package_metadata,
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
# <This is the place where bundles are restarted as an effect of package X
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
# 1) CQ instance works properly - 200 is returned for login page
# 2) com.adobe.granite.crx-packagemgr bundle is Active
# 3) http://<INSTANCE>:<PORT>/crx/packmgr/service.jsp returns 200
#
# All items are actively sampled every 10 seconds up to 30 checks (5
# minutes). As soon as first requirement is fulfilled 2nd check is verified
# with the same frequency (and so on).If any of them fails after 30 checks Chef
# run is aborted.

# 1st requirement - CQ works fine
def instance_healthcheck
  cmd_str = "curl -s -o /dev/null -w '%{http_code}' "\
            "-u #{new_resource.username}:#{new_resource.password} "\
            "#{new_resource.instance}#{node['cq']['healthcheck_resource']}"

  Chef::Log.info('Verifying general instance state before proceeding with '\
                 'package operation.')

  i_max = 30

  (1..i_max).each do |i|
    Chef::Log.debug("CQ instance - status check: [#{i}/#{i_max}]")
    cmd = Mixlib::ShellOut.new(cmd_str, :timeout => 180)
    cmd.run_command

    begin
      cmd.error!

      # Exit immediately if returned status code equals 200
      break if cmd.stdout == '200'
    rescue => e
      Chef::Log.error "Unable to retrive HTTP status from CQ instance.\n"\
        "Error description: #{e}"
    end

    Chef::Application.fatal!("CQ instance didn't return 200 for 5 minutes. "\
                             'Aborting...') if i == i_max
    sleep 10
  end

  Chef::Log.info('Instance returned 200. Moving on...')
end

# 2nd requirement: OSGi bundle is in "Active" state
def pkg_mgr_bundle_healthcheck
  cmd_str = "#{node['cq-unix-toolkit']['install_dir']}/cqosgi -m "\
            "-i #{new_resource.instance} "\
            "-u #{new_resource.username} "\
            "-p #{new_resource.password} "\
            "| grep 'com.adobe.granite.crx-packagemgr' "\
            "| awk '{printf \"%s\", $3}'"

  Chef::Log.info('Verifying CRX Package Manager bundle')

  i_max = 30

  (1..i_max).each do |i|
    Chef::Log.debug("Package Manager bundle - status check: [#{i}/#{i_max}]")
    cmd = Mixlib::ShellOut.new(cmd_str, :timeout => 180)
    cmd.run_command

    begin
      cmd.error!

      # Sanitize the output
      cmd_out_sanitized = cmd.stdout.strip.gsub('\n', '')

      # Break if bundle is in "Active" state
      break if cmd_out_sanitized == 'Active'
    rescue => e
      Chef::Log.error "Unable to retrive CRX Package Manager bundle state.\n"\
        "Error description: #{e}"
    end

    Chef::Application.fatal!(
      'Cannot proceed as CRX Package Manager bundle '\
      "is still in #{cmd_out_sanitized} state"
    ) if i == i_max
    sleep 10
  end

  Chef::Log.info('Package Manager bundle is in Active state. Moving on...')
end

# 3rd requirement: package listing using API works correctly
def pkg_mgr_api_healthcheck
  cmd_str = "curl -s -o /dev/null -w '%{http_code}' "\
            "-u #{new_resource.username}:#{new_resource.password} "\
            "#{new_resource.instance}/crx/packmgr/service.jsp -F cmd=ls"

  Chef::Log.info('Verifying CRX Package Manager API status code')

  i_max = 30

  (1..i_max).each do |i|
    Chef::Log.debug("Package Manager bundle - status check: [#{i}/#{i_max}]")
    cmd = Mixlib::ShellOut.new(cmd_str, :timeout => 180)
    cmd.run_command

    begin
      cmd.error!
      break if cmd.stdout == '200'
    rescue => e
      Chef::Log.error "Unable to list packages using Package Manager API.\n"\
        "Error description: #{e}"
    end

    Chef::Application.fatal!("Cannot proceed as package listing didn't work "\
                             'for 5 minutes') if i == i_max
    sleep 10
  end

  Chef::Log.info('Package Manager API works correctly. Moving on...')
end

# Detect changes in bundle state. X seconds without changes is considered as a
# "safe" state.
def osgi_stability_healthcheck
  cmd_str = "curl -s -u #{new_resource.username}:#{new_resource.password} "\
            "#{new_resource.instance}/system/console/bundles/.json"

  Chef::Log.info('Waiting for stable state of OSGi bundles...')

  # Previous state of OSGi bundles (start with empty)
  previous_state = ''

  # How many times the state hasn't changed in a row
  same_state_counter = 0

  # Number of iterations
  i_max = 120

  (1..i_max).each do |i|
    cmd = Mixlib::ShellOut.new(cmd_str, :timeout => 180)
    cmd.run_command

    begin
      cmd.error!

      if cmd.stdout == previous_state
        same_state_counter += 1
      else
        same_state_counter = 0
      end

      # Assign current state to previous state
      previous_state = cmd.stdout

      # Move on if the same state occurred N times in a row
      break if same_state_counter == 3
    rescue => e
      Chef::Log.warn 'Unable to get OSGi bundles state. Retrying...'

      # Let's start over in case of an error (clear indicator of flapping OSGi
      # bundles)
      previous_state = ''
      same_state_counter = 0
    end

    Chef::Application.fatal!("Cannot detect stable state after #{i_max} "\
                             'attempts. Aborting...') if i == i_max
    sleep 10
  end

  Chef::Log.info('OSGi bundles seem to be stable. Moving on...')
end

# Initializes CRX attributes for already uploaded packages
def init_crx_attributes
  @crx_name = package_attr_from_object(package_info, 'name')
  @crx_version = package_attr_from_object(package_info, 'version')
  @crx_group = package_attr_from_object(package_info, 'group')
  # It turned out downloadName attr may contain blank characters (see AEM6
  # Service Pack 1). Let's get rid of these before any interaction with CRX
  # Package Manager.
  @crx_downloadname =
    package_attr_from_object(package_info, 'downloadName').gsub(' ', '%20')
end

# Loads current resource and all accessor attributes
def load_current_resource
  # Pre-flight checks - make sure that everything is working as expected before
  # moving on
  instance_healthcheck
  pkg_mgr_bundle_healthcheck
  pkg_mgr_api_healthcheck

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

  # Init CRX related attributes (already uploaded packages only)
  init_crx_attributes
end

# Uploads package to a given CQ instance
def upload_package
  cmd_str = "#{node['cq-unix-toolkit']['install_dir']}/cqput "\
            "-i #{new_resource.instance} "\
            "-u #{new_resource.username} "\
            "-p #{new_resource.password} " +
            package_path
  cmd = Mixlib::ShellOut.new(cmd_str, :timeout => 600)
  Chef::Log.info "Uploading package #{new_resource.name}"
  cmd.run_command

  begin
    cmd.error!
    Chef::Log.info "Package #{new_resource.name} has been successfully "\
                   'uploaded'
    # Invalidate internal cache after package upload
    @package_list = nil
  rescue => e
    Chef::Application.fatal!("Can't upload package #{new_resource.name}!\n"\
                             "Error description: #{e}")
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

  cmd_str = "curl -s -X POST -w ';%{http_code}' "\
            "-u #{new_resource.username}:#{new_resource.password} "\
            "#{new_resource.instance}/crx/packmgr/service/.json/etc/packages"

  # Empty group fix
  if @crx_group.empty?
    cmd_str += "/#{@crx_downloadname}?cmd=install"
  else
    cmd_str += "/#{@crx_group}/#{@crx_downloadname}?cmd=install"
  end

  # Add recursive flag if requested
  cmd_str += '\&recursive=true' if new_resource.recursive_install == true

  cmd = Mixlib::ShellOut.new(cmd_str, :timeout => 1800)
  Chef::Log.info "Installing package #{new_resource.name}"
  cmd.run_command

  begin
    cmd.error!
    Chef::Log.info "Package #{new_resource.name} has been successfully "\
      'installed.'
  rescue => e
    Chef::Application.fatal!("Can't install package #{new_resource.name}!\n"\
                             "Error description: #{e}")
  end

  # Invalidate internal cache after package installation
  @package_list = nil

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

  Chef::Application.fatal!('Not successful package operation: ' +
                            output[0]) if json_resp['success'] != true

  # Wait for stable state of OSGi bundles. Installation of a package (hotfixes/
  # service packs in particular) may cause a lot bundle restarts, which
  # prevents further operations against CQ/AEM APIs.
  osgi_stability_healthcheck
end

# Uninstalls given CQ package
#
# cqrev command from CQ UNIX Toolkit uses old Package Manager API, hence it
# can't be used here (same reasons as for install action)
#
# Stdout of curl command:
# <response_json>;<http_status>
#
# Example:
# {"msg": "Package uninstalled", "success": true};200
def uninstall_package
  require 'json'

  cmd_str = "curl -s -X POST -w ';%{http_code}' "\
            "-u #{new_resource.username}:#{new_resource.password} "\
            "#{new_resource.instance}/crx/packmgr/service/.json/etc/packages"

  # Empty group fix
  if @crx_group.empty?
    cmd_str += "/#{@crx_downloadname}?cmd=uninstall"
  else
    cmd_str += "/#{@crx_group}/#{@crx_downloadname}?cmd=uninstall"
  end

  cmd = Mixlib::ShellOut.new(cmd_str, :timeout => 1800)
  Chef::Log.info "Uninstalling package #{new_resource.name}"
  cmd.run_command

  begin
    cmd.error!
    Chef::Log.info "Package #{new_resource.name} has been successfully "\
      'uninstalled.'
  rescue => e
    Chef::Application.fatal!("Can't uninstall package #{new_resource.name}!\n"\
                             "Error description: #{e}")
  end

  # Invalidate internal cache after package uninstallation
  @package_list = nil

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

  Chef::Application.fatal!('Not successful package operation: ' +
                            output[0]) if json_resp['success'] != true

  # Wait for stable state of OSGi bundles (every operation that affects OSGi
  # should do that)
  osgi_stability_healthcheck
end

action :upload do
  if @current_resource.uploaded
    Chef::Log.info("Package #{new_resource.name} is already uploaded - "\
                   'nothing to do')
  else
    converge_by("Upload #{new_resource}") do
      upload_package
    end
  end
end

action :install do
  if @current_resource.uploaded
    if @current_resource.installed
      Chef::Log.info("Package #{new_resource.name} is already installed - "\
                    'nothing to do')
    else
      converge_by("Install #{new_resource}") do
        install_package
      end
    end
  else
    Chef::Log.error(
      "#{@current_resource}: can't install not yet uploaded package!"
    )
  end
end

action :deploy do
  if @current_resource.uploaded
    if @current_resource.installed
      Chef::Log.info(
        "Package #{new_resource.name} is already deployed (uploaded and "\
        'installed).'
      )
    else
      converge_by("Install #{new_resource}") do
        install_package
      end
    end
  else
    converge_by("Upload and install #{new_resource}") do
      upload_package

      # Populate not yet initialized variables
      init_crx_attributes

      install_package
    end
  end
end

action :uninstall do
  if @current_resource.installed
    converge_by("Uninstall #{new_resource}") do
      uninstall_package
    end
  else
    if @current_resource.uploaded
      Chef::Log.warn("Package #{new_resource} is already uninstalled")
    else
      Chef::Log.warn("Can't uninstall not existing package!")
    end
  end
end
