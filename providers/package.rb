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

action :upload do
  cmd_str = "#{node[:cq_unix_toolkit][:install_dir]}/cqput "\
            "-i #{@new_resource.instance} "\
            "-u #{@new_resource.username} "\
            "-p #{@new_resource.password} "\
            "#{@new_resource.source}"
  cmd = Mixlib::ShellOut.new(cmd_str)
  cmd.run_command
  Chef::Log.info "cq_package_upload command: #{cmd_str}"
  Chef::Log.info "cq_package_upload stdout: #{cmd.stdout}"
  Chef::Log.info "cq_package_upload stderr: #{cmd.stderr}"
  begin
    cmd.error!
    true
  rescue
    Chef::Application.fatal!("Can't upload package #{@new_resource.name}:\
                             #{cmd.stdout}")
  end
end
