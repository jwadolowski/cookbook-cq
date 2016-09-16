# ~FC015
#
# Cookbook Name:: cq
# Definition:: osgi_config_wrapper
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

# -----------------------------------------------------------------------------
# This definition was created for test purpose only. Please do not use it
# outside of test kitchen suites.
# -----------------------------------------------------------------------------

define :osgi_config_wrapper,
       :properties => {},
       :append => true,
       :factory => false,
       :force => false,
       :unique_fields => [],
       :count => 1,
       :enforce_count => false,
       :action => :create do
  ruby_block "start timestamp for #{params[:name]}" do
    block do
      sleep 1 # Wait a second to separate log events
      File.write(
        "/tmp/#{params[:name]}_start_timestamp",
        Time.now.strftime('%d/%b/%Y %H:%M:%S')
      )
    end

    not_if { ::File.exist?("/tmp/#{params[:name]}_start_timestamp") }
  end

  cq_osgi_config params[:name] do
    username node['cq']['author']['credentials']['login']
    password node['cq']['author']['credentials']['password']
    instance "http://localhost:#{node['cq']['author']['port']}"
    append params[:append]
    force params[:force]
    properties(params[:properties])
    factory_pid params[:name] if params[:factory]
    unique_fields params[:unique_fields]
    count params[:count]
    enforce_count params[:enforce_count]

    action params[:action]
  end

  ruby_block "stop timestamp for #{params[:name]}" do
    block do
      sleep 1 # Wait a second to separate log events
      File.write(
        "/tmp/#{params[:name]}_stop_timestamp",
        Time.now.strftime('%d/%b/%Y %H:%M:%S')
      )
    end

    not_if { ::File.exist?("/tmp/#{params[:name]}_stop_timestamp") }
  end
end
