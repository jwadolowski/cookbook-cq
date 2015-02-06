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

# Get a list of all OSGi configurations
#
# @return [String] list of all OSGi configurations
def osgi_config_list
  cmd_str = "#{node['cq-unix-toolkit']['install_dir']}/cqcfgls "\
            "-i #{new_resource.instance} "\
            "-u #{new_resource.username} "\
            "-p #{new_resource.password} "

  cmd = Mixlib::ShellOut.new(cmd_str)
  cmd.run_command

  Chef::Log.debug("Executing #{cmd_str}")

  begin
    cmd.error!
    cmd.stdout
  rescue => e
    Chef::Application.fatal!("Can't get a list of OSGi configurations!\n"\
                             "Error description: #{e}")
  end
end

# Checks presence of OSGi config
#
# @return [Boolean] true if OSGi config exists, false otherwise
def osgi_config_presence
  osgi_config_list.include? new_resource.pid
end

# Get properties of existing OSGi configuration
#
# @return [JSON] properties of given OSGi configuration
def osgi_config_properties
  cmd_str = "#{node['cq-unix-toolkit']['install_dir']}/cqcfg "\
            "-i #{new_resource.instance} "\
            "-u #{new_resource.username} "\
            "-p #{new_resource.password} "\
            '-j ' +
            new_resource.pid

  cmd = Mixlib::ShellOut.new(cmd_str)
  cmd.run_command

  begin
    cmd.error!
    JSON.parse(cmd.stdout)['properties']
  rescue => e
    Chef::Application.fatal!("Can't get #{new_resource.pid} properties!\n"\
                             "Error description: #{e}")
  end
end

# Parse OSGi config properties to get a simple hash (key-value) from all items.
# Additionally sort and get rid of duplicated entries (if any)
#
# @return [Hash] key value pairs
def current_properties_hash
  kv = {}

  osgi_config_properties.each_pair do |key,val|
    kv[key] = val['value']
    kv[key] = val['values'].sort.uniq if kv[key].nil?
  end

  kv
end

# Compares properties of new and current resources
#
# @return [Boolean] true if properties match, false otherwise
def validate_properties
  sanitized_new_properties.to_a.sort.uniq ==
    current_resource.properties.to_a.sort.uniq
end

# Sanitize new resource properties (sort and get rid of duplicates)
#
# @return [Hash] sanitized hash of new resource properties
def sanitized_new_properties
  local_properties = @new_resource.properties

  local_properties.each do |k,v|
    if v.kind_of?(Array)
      local_properties[k] = v.sort.uniq
    end
  end

  local_properties
end

def load_current_resource
  Chef::Log.error("New resource properties: #{new_resource.properties}")

  @current_resource = Chef::Resource::CqOsgiConfig.new(new_resource.pid)

  # Set attribute accessors
  @current_resource.exists = osgi_config_presence

  # Load OSGi properties for existing configuration and check validity
  if current_resource.exists
    @current_resource.properties(current_properties_hash)
    @current_resource.valid = validate_properties
    Chef::Log.error("Current resource: #{current_resource.properties}")
    Chef::Log.error("New resource: #{sanitized_new_properties}")
    Chef::Log.error(">>> valid?: #{current_resource.valid}")
  end
end

# Converts properties hash to -s KEY -v VALUE string for cqcfg execution
#
# @return [String] key/value string for cqcfg exec
def cqcfg_params
  param_str = ''

  sanitized_new_properties.each do |k,v|
    if v.kind_of?(Array)
      v.each do |v1|
        param_str += "-s #{k} -v #{v1} "
      end
    else
      param_str += "-s #{k} -v #{v} "
    end
  end

  param_str
end

# Create OSGi config with given attributes. If OSGi config already exists (but
# does not match), it will update that OSGi config to match.
def create_osgi_config
  cmd_str = "#{node['cq-unix-toolkit']['install_dir']}/cqcfg "\
            "-i #{new_resource.instance} "\
            "-u #{new_resource.username} "\
            "-p #{new_resource.password} " +
            cqcfg_params + new_resource.pid

  cmd = Mixlib::ShellOut.new(cmd_str)
  cmd.run_command

  begin
    cmd.error!
  rescue => e
    Chef::Application.fatal!("Can't update #{new_resource.pid} properties!\n"\
                             "Error description: #{e}")
  end
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
  if !@current_resource.exists
    Chef::Log.error("OSGi config #{new_resource.pid} does NOT exists!")
  elsif @current_resource.exists && @current_resource.valid
    Chef::Log.info("OSGi config #{new_resource.pid} is already in valid "\
                   'state - nothing to do')
  else
    converge_by("Create #{ new_resource }") do
      create_osgi_config
    end
  end
end
