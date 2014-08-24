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

  # Get list of packages using CQ UNIX Toolkit
  cmd_str = "#{node[:cq_unix_toolkit][:install_dir]}/cqls -x "\
            "-i #{new_resource.instance} "\
            "-u #{new_resource.username} "\
            "-p #{new_resource.password}"
  Chef::Log.debug("Command: #{cmd_str}")
  cmd = Mixlib::ShellOut.new(cmd_str)
  cmd.run_command
  begin
    cmd.error!
  rescue
    Chef::Application.fatal!("Cannot get package list: #{cmd.stderr}")
  end

  # Extract and return <packages> element from original XML
  begin
    REXML::XPath.first(REXML::Document.new(cmd.stdout), '//packages')
  rescue => e
    Chef::Application.fatal!("Cannot parse XML returned by CQ instance: #{e}")
  end
end

# Looks for a package on a given CQ instance
#
# @param package_name [String] package name to look for
# @return [Array] an array of REXML::Element objects with package info
def package_info(package_name)
  require 'rexml/document'

  packages = []

  # Iterate thorugh packages and get info about package you're looking for
  package_list.elements.each('package') do |pkg|
    packages.push(pkg) if pkg.elements['name'].text == package_name
  end

  packages
end

# Extract raw information from package metadata
#
# @param type [String] metadata type, accepted values: properties, filters
# @retrurn [REXML::Document] raw XML object
def package_metadata(type)
  require 'rexml/document'

  case type
  when 'properties'
    cmd_str = "#{node[:cq_unix_toolkit][:install_dir]}/cqrepkg -P "\
      "#{package_path}"
  when 'filters'
    cmd_str = "#{node[:cq_unix_toolkit][:install_dir]}/cqrepkg -F "\
      "#{package_path}"
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
    return REXML::XPath.first(package_metadata('properties'),
                              "//entry[@key='#{attr_name}']").text
  rescue => e
    Chef::Application.fatal!("Cannot get package #{attr_name} from XML "\
                             "object: #{e}")
  end
end

# Gets package attribute from CRX package object
#
# @param pkg_xml [REXML::Document] package XML object
# @param attr_name [String] package attribute to look for
# @return [String] package attribute
def package_attr_from_object(pkg_xml, attr_name)
  require 'rexml/document'

  begin
    return pkg_xml.elements[attr_name].text
  rescue => e
    Chef::Application.fatal!("Cannot get package #{attr_name} from XML "\
                             "object: #{e}")
  end
end

# Sets uploaded attribute if package is uploaded to given instance
#
# @return [Boolean] true if package is already uploaded, false otherwise
def package_uploaded?
  # New resource attrs
  pkg_name = package_attr_from_metadata('name')
  pkg_ver = package_attr_from_metadata('version')
  Chef::Log.debug('New resource: '\
                  "name = #{pkg_name}, "\
                  "version = #{pkg_ver}")

  # Look for packages in CRX Package Manager
  pkg_info = package_info(pkg_name)

  # Return false if 0 packages with given name have been found
  return false if pkg_info.empty?

  # Look for specifc version of CQ package
  pkg_info.each do |pkg|
    current_pkg_ver = package_attr_from_object(pkg, 'version')
    Chef::Log.debug('Current resource: '\
                    "name = #{package_attr_from_object(pkg, 'name')}, "\
                    "version = #{current_pkg_ver}")

    return true if pkg_ver == current_pkg_ver
  end

  # Return false if there's no package with given version
  false
end

# Sets installed attribute if package is already installed
#
# @return [Boolean] true if package is already installed, false otherwise
def package_installed?
  # Package has to be uploaded first to be considered installed
  return false if @uploaded == false

  # New resource attrs
  pkg_name = package_attr_from_metadata('name')
  pkg_ver = package_attr_from_metadata('version')

  installed_pkgs = []

  # Gather packages with lastUnpacked attribute set
  package_info(pkg_name).each do |pkg|
    Chef::Log.debug("AAAAAAAAA #{pkg.to_s}")
    unless package_attr_from_object(pkg, 'lastUnpacked').nil?
      installed_pkgs.push(pkg)
    end
  end

  # 0 packages have been installed - return false
  return false if installed_pkgs.empty?

  # Look for the package with the newest lastUnpacked element
  newest_pkg = ''

  installed_pkgs.each_cons(2) do |pkg1, pkg2|
    newest_pkg = pkg1
    if DateTime.parse(package_attr_from_object(pkg1, 'lastUnpacked')) <
      DateTime.parse(package_attr_from_object(pkg2, 'lastUnpacked'))
      newest_pkg = pkg2
    end
  end

  Chef::Log.debug("Newest installed package: #{newest_pkg.to_s}")

  # Compare the version of new resource and already installed resource
  if pkg_ver == package_attr_from_object(newest_pkg, 'version')
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

# Loads current resource and all accessor attributes
def load_current_resource
  @current_resource = Chef::Resource::CqPackage.new(new_resource.name)

  # Load "state" attributes from new resource
  @current_resource.username(new_resource.username)
  @current_resource.password(new_resource.password)
  @current_resource.instance(new_resource.instance)

  # Set attribute acccessors
  @current_resource.uploaded = package_uploaded?
  @current_resource.installed = package_installed?
end

# Uploads package to a given CQ instance
def upload_package
  cmd_str = "#{node[:cq_unix_toolkit][:install_dir]}/cqput "\
            "-i #{new_resource.instance} "\
            "-u #{new_resource.username} "\
            "-p #{new_resource.password} "\
            "#{package_path}"
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
    Chef::Application.fatal!("Can't upload package #{new_resource.name}: "\
                             "#{cmd.stderr}")
  end
end

# Installs CQ package
def install_package
  # TODO: installation impl
  true
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
