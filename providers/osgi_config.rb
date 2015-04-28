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

  begin
    cmd.error!
    cmd.stdout
  rescue => e
    Chef::Application.fatal!("Can't get a list of OSGi configurations!\n"\
                             "Error description: #{e}")
  end
end

# Returns all OSGi configs created from a specific factory
#
# @return [Array of Strings] all factory configs that matches factory pid
def factory_config_list
  # Convert factory pid to a regex form and add a suffix to match just
  # instances and not the factory pid itself.
  #
  # Format: <factory_pid>\.<uuid>
  regex = new_resource.factory_pid.gsub(/\./, '\.') + '\.' +
    '[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}'

  osgi_config_list.scan(/#{regex}/)
end

# Compares all instances of a given factory config and returns a hash with
# PIDs (keys) and scores (valus)
#
# @return [Hash] comparison hash
def compatibility_hash
  # Hash that stores the following key-value pairs:
  #
  # | KEY            | VALUE |
  # | -------------- | ----- |
  # | factory_config | [0-N] |
  output = {}

  # Compare new resource against all factory configs
  factory_config_list.each do |config|
    output[config] = compatibility_score(config)
  end

  output
end

# Validates given config against new resource properties and returns the score
# (number of common attributes)
#
# @param factory_instance [String] PID name of a factory based config
# @return [Integer] numer of common properties
def compatibility_score(factory_instance)
  factory_config_properties = properties_hash(
    osgi_config_properties(factory_instance)
  )

  score = 0

  new_resource.properties.each do |key, val|
    score +=1 if factory_config_properties[key] == val
  end

  score
end

# Analyzes score hash returned by compatibility_hash and picks the highest
# score
#
# @return [Integer] highest value from hash
def max_compatibility_score
  hash = compatibility_hash

  if hash.empty?
    0
  else
    hash.max_by { |k, v| v }[1]
  end
end

# Get all items that have the highest compatibility score
#
# @return [Hash] hash of factory config instances with the highest score
def matching_candidates
  compatibility_hash.select { |k, v| v == max_compatibility_score }
end

# Analyzes both compatibility scores and new_resource properties to pick the
# best candidate (if any)
#
# @return [String, Nil] name of the config or Nil if none of configs match
def best_candidate_pid
  # Score of the config has to be greater than 0 and equal to the number of
  # key-value pairs in new_resource properties hash to be taken into
  # consideration as a matching candidate
  if max_compatibility_score < new_resource.properties.length
    nil
  else
    candidates = matching_candidates

    case candidates.length
    when 1
      candidates.keys[0]
    else
      Chef::Application.fatal!(
        "More than 1 existing OSGi config matches to #{new_resource.name}. "\
        'Please make sure that your cq_osgi_config resource matches either '\
        'to a single configuration or none of existing ones'
      )
    end
  end
end

# Checks presence of OSGi config
#
# @return [Boolean] true if OSGi config exists, false otherwise
def osgi_config_presence
  if new_resource.factory_pid.nil?
    osgi_config_list.include? new_resource.pid
  else
    if best_candidate_pid.nil?
      false
    else
      true
    end
  end
end

# Get properties of existing OSGi configuration
#
# @param name [String] the name the config (PID)
# @return [JSON] properties of given OSGi configuration
def osgi_config_properties(name)
  cmd_str = "#{node['cq-unix-toolkit']['install_dir']}/cqcfg "\
            "-i #{new_resource.instance} "\
            "-u #{new_resource.username} "\
            "-p #{new_resource.password} "\
            '-j ' +
            name

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
# @param properties [JSON] properties in JSON format
# @return [Hash] key value pairs
def properties_hash(properties)
  kv = {}

  properties.each_pair do |key, val|
    kv[key] = val['value']
    kv[key] = val['values'].sort.uniq if kv[key].nil?
  end

  kv
end

# Returns merged properties from new and current resources
#
# @return [Hash] merged properties
def merged_properties
  current_resource.properties.merge(
    new_resource.properties) do |key, oldval, newval|
      if oldval.is_a?(Array)
        (oldval + newval)
      else
        newval
      end
  end
end

# Compares properties of new and current resources
#
# @return [Boolean] true if properties match, false otherwise
def validate_properties
  sanitized_new_properties.to_a.sort.uniq ==
    current_resource.properties.to_a.sort.uniq
end

# Sanitize new resource properties (sort and get rid of duplicates). Takes
# 'append' attribute into account and returns merged properties (new +
# current) if it's set to true.
#
# @return [Hash] sanitized hash of new resource properties
def sanitized_new_properties
  if new_resource.append
    local_properties = merged_properties
  else
    local_properties = @new_resource.properties
  end

  local_properties.each do |k, v|
    local_properties[k] = v.sort.uniq if v.is_a?(Array)
  end

  local_properties
end

def load_current_resource
  @current_resource = Chef::Resource::CqOsgiConfig.new(new_resource.pid)

  # Set attribute accessors
  @current_resource.exists = osgi_config_presence

  # Initialize current resource properties (will be overwritten later on if
  # required)
  @current_resource.properties({})

  # For non-factory configs choose PID of current resource, otherwise look for
  # best candidate
  if new_resource.factory_pid.nil?
    config_name = current_resource.pid
  else
    config_name = best_candidate_pid

    # Update new_resource PID with best candidate's PID (but only if such
    # exists)
    @new_resource.pid(config_name) unless config_name.nil?
  end

  # Load OSGi properties for existing configuration and check validity
  if current_resource.exists
    @current_resource.properties(
      properties_hash(osgi_config_properties(config_name))
    )
    @current_resource.valid = validate_properties
  end
end

# Converts properties hash to -s KEY -v VALUE string for cqcfg execution
#
# @return [String] key/value string for cqcfg exec
def cqcfg_params
  param_str = ''

  sanitized_new_properties.each do |k, v|
    if v.is_a?(Array)
      v.each do |v1|
        param_str += "-s \"#{k}\" -v \"#{v1}\" "
      end
    else
      param_str += "-s \"#{k}\" -v \"#{v}\" "
    end
  end

  param_str
end

# Create OSGi config with given attributes. If OSGi config already exists (but
# does not match), it will update that OSGi config to match
#
# @param factory_flag [Boolean] use or not factory flag (false by default)
def create_osgi_config(factory_flag=false)
  cmd_str_base = "#{node['cq-unix-toolkit']['install_dir']}/cqcfg "\
                 "-i #{new_resource.instance} "\
                 "-u #{new_resource.username} "\
                 "-p #{new_resource.password} " +
                 cqcfg_params

  if factory_flag
    cmd_str = cmd_str_base + "-f #{new_resource.factory_pid}"
  else
    cmd_str = cmd_str_base + new_resource.pid
  end

  cmd = Mixlib::ShellOut.new(cmd_str)
  cmd.run_command

  begin
    cmd.error!
  rescue => e
    Chef::Application.fatal!("Can't update #{new_resource.pid} properties!\n"\
                             "Error description: #{e}")
  end
end

# Delete OSGi config
def delete_osgi_config
  # TODO
end

action :create do
  if !@current_resource.exists
    # Non-factory configs
    if @new_resource.factory_pid.nil?
      Chef::Log.error("OSGi config #{new_resource.pid} does NOT exists!")
    # Factory configs
    else
      converge_by("Create #{new_resource}") do
        create_osgi_config(true)
      end
    end
  elsif @current_resource.exists && @current_resource.valid
    Chef::Log.info("OSGi config #{new_resource.pid} is already in valid "\
                   'state - nothing to do')
  else
    converge_by("Create #{new_resource}") do
      create_osgi_config
    end
  end
end
