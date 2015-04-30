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

define :osgi_config_wrapper, :properties => nil, :append => false do
  ruby_block "start timestamp for #{params[:name]}" do
    block do
      File.write(
        "/tmp/#{params[:name]}_start_timestamp",
        Time.now.strftime('%d/%b/%Y %H:%M:%S')
      )
    end

    not_if { ::File.exists?("/tmp/#{params[:name]}_start_timestamp") }
  end

  cq_osgi_config params[:name] do
    username node['cq']['author']['credentials']['login']
    password node['cq']['author']['credentials']['password']
    instance "http://localhost:#{node['cq']['author']['port']}"
    append params[:append]
    properties(params[:properties])

    action :create
  end

  ruby_block "stop timestamp for #{params[:name]}" do
    block do
      File.write(
        "/tmp/#{params[:name]}_stop_timestamp",
        Time.now.strftime('%d/%b/%Y %H:%M:%S')
      )
    end

    not_if { ::File.exists?("/tmp/#{params[:name]}_stop_timestamp") }
  end
end
