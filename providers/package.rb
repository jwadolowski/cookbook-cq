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

# Detects source attribute of cq_package reosurce
#
# Value of source attribute can be an URI or local path
# * URI - file is downloaded and download path is return
# * not-URI - local path is assumed
#
# Allowed URI schemes:
# * http://
# * https://
def package_path
  begin
    src = URI.parse(@new_resource.source)
  rescue URI::InvalidURIError
    Chef::Application.fatal!("Cannot parse #{@new_resource.source} as an URI")
  end
  if (src.instance_of? URI::HTTP) || (src.instance_of? URI::HTTPS)
    return get_remote_file(src.to_s,
                           @new_resource.http_user,
                           @new_resource.http_pass)
  else
    return @new_resource.source
  end
end

# Download file
#
# Arguments:
# * uri - remote location of a file
# * http_user - user for HTTP basic authentication
# * http_pass - password for HTTP basic authentication
# * cache_dir - path used to store downloaded file
def get_remote_file(uri,
                    http_user,
                    http_pass,
                    cache_dir = Chef::Config[:file_cache_path])
  file_name = Pathname.new(URI.parse(uri).path).basename.to_s
  dst_path = "#{cache_dir}/#{file_name}"
  Chef::Log.info("Downloading package from #{uri}")
  begin
    if http_user.empty? || http_pass.empty?
      open(uri) do |f|
        File.open(dst_path, 'wb') do |file|
          file.puts f.read
        end
      end
    else
      open(uri,
           http_basic_authentication: [http_user, http_pass]) do |f|
        ::File.open(dst_path, 'wb') do |file|
          file.puts f.read
        end
      end
    end
  rescue OpenURI::HTTPError => e
    Chef::Application.fatal!('Something went wrong while downloading '\
                             "package from #{@new_resource.source}: "\
                             "#{e.message}")
  end

  Chef::Log.info("Package #{@new_resource.name} has been downloaded to "\
                 "#{dst_path}")
  # Retrun local path to downloaded package
  dst_path
end

action :upload do
  cmd_str = "#{node[:cq_unix_toolkit][:install_dir]}/cqput "\
            "-i #{@new_resource.instance} "\
            "-u #{@new_resource.username} "\
            "-p #{@new_resource.password} "\
            "#{package_path}"
  cmd = Mixlib::ShellOut.new(cmd_str)
  Chef::Log.info "Uploading package #{new_resource.name}"
  cmd.run_command
  Chef::Log.debug "cq_package_upload command: #{cmd_str}"
  Chef::Log.debug "cq_package_upload stdout: #{cmd.stdout}"
  Chef::Log.debug "cq_package_upload stderr: #{cmd.stderr}"
  begin
    cmd.error!
    Chef::Log.info "Package #{@new_resource.name} has been successfully "\
                   'uploaded'
  rescue
    Chef::Application.fatal!("Can't upload package #{@new_resource.name}: "\
                             "#{cmd.stderr}")
  end
end
