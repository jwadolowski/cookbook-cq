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

use_inline_resources

# Calucates Authorization HTTP header value
#
# @return [String] encoded HTTP header value compliant with the standard
def auth_header_value
  Base64.encode64("#{new_resource.http_user}:#{new_resource.http_pass}")
end

# Validates source attribute of cq_package resource.
# To pass it has to be valid HTTP/HTTP URI.
#
# @return [URI] valid/parsed URI object
def validate_source
  begin
    src = URI.parse(new_resource.source)
    unless src.instance_of?(URI::HTTP) || src.instance_of?(URI::HTTPS)
      Chef::Application.fatal!("#{new_resource.source} is valid URI, but is "\
                               'not an instance of HTTP/HTTPS URI!')
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

# Downloads CQ package from HTTP/HTTPS endpoints using built-in (platform)
# remote_file resource
#
# @return [Chef::Resource::RemoteFile]
def download_package
  src = validate_source
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
end

action :upload do
  # TODO: add validation via load_current_resource
  download_package

  cmd_str = "#{node[:cq_unix_toolkit][:install_dir]}/cqput "\
            "-i #{new_resource.instance} "\
            "-u #{new_resource.username} "\
            "-p #{new_resource.password} "\
            "#{@dst_path}"
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
