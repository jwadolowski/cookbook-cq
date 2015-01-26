#
# Cookbook Name:: cq
# Provider:: osgi_config
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

def osgi_config_metadata
  cmd_str = "#{node['cq-unix-toolkit']['install_dir']}/cqcfg "\
            "-i #{new_resource.instance} "\
            "-u #{new_resource.username} "\
            "-p #{new_resource.password} " +
            new_resource.name

  cmd = Mixlib::ShellOut.new(cmd_str)
  cmd.run_command

  begin
    cmd.error!
    Chef::Log.info "#{new_resource.name} metadata: #{cmd.stdout}"
  rescue
    Chef::Application.fatal!("Can't get #{new_resource.name} metadata!\n"\
                             "Error description: #{e}")
  end
end

def load_current_resource
  @current_resource = Chef::Resource::CqOsgiConfig.new(new_resource.name)

  # Set attribute accessors
  @current_resource.created = false

  # Load properties from OSGi console
  # TODO
end

# Create OSGi config with given attributes. If OSGi config already exists (but
# does not match), it will update that OSGi config to match.
def create_osgi_config
  # TODO
  osgi_config_metadata
end

# Delete OSGi config.
def delete_osgi_config
  # TODO
end

# Modify an existing config. It will raise an exception if item does not exist.
def modify_osgi_config
  # TODO
end

# Modify an existing config. It will not raise an exception if item does not
# exist.
def manage_osgi_config
  # TODO
end

action :create do
  if @current_resource.created
    Chef::Log.info("OSGi config #{new_resource.name} is already created and "\
                   ' properly configured - nothing to do')
  else
    converge_by("Create #{ new_resource }") do
      create_osgi_config
    end
  end
end
