# ~FC015
#
# Cookbook Name:: cq
# Definition:: daemon
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

define :cq_daemon,
       :mode => nil do

  # Helpers
  # ---------------------------------------------------------------------------
  local_mode = params[:mode]
  daemon_name = cq_daemon_name(local_mode)

  # Create init script
  # ---------------------------------------------------------------------------
  template "/etc/init.d/#{daemon_name}" do
    owner node['cq']['user']
    group node['cq']['group']
    mode '0755'
    source 'cq.init.erb'
    variables(
      :daemon_name => daemon_name,
      :full_name => "Adobe CQ #{node['cq']['version']}"\
                    " #{local_mode.to_s.capitalize}",
      :conf_file => "#{cq_instance_conf_dir(node['cq']['home_dir'],
                                            local_mode)}/"\
                                            "#{daemon_name}.conf"
    )
  end

  # Start instance
  # ---------------------------------------------------------------------------
  service daemon_name do
    supports :status => true, :restart => true
    action [:enable, :start]
  end

  # Wait until CQ is fully up and running
  # ---------------------------------------------------------------------------
  ruby_block "#{daemon_name} start guard" do # ~FC014
    block do
      require 'net/http'
      require 'uri'

      # Pick valid resource to verify CQ instance full start
      if constraint('~> 5.6.0').satisfied_by?(node['cq']['version'])
        uri = URI.parse("http://localhost:#{node['cq'][local_mode]['port']}"\
                        '/libs/granite/core/content/login.html')
      elsif constraint('~> 5.5.0').satisfied_by?(node['cq']['version'])
        uri = URI.parse("http://localhost:#{node['cq'][local_mode]['port']}"\
                        '/libs/cq/core/content/login.html')
      elsif constraint('~> 6.0.0').satisfied_by?(node['cq']['version'])
        uri = URI.parse("http://localhost:#{node['cq'][local_mode]['port']}"\
                        '/libs/granite/core/content/login.html')
      end

      # Start timeout (15 min)
      timeout = 900

      response = '-1'
      start_time = Time.now

      # Keep asking CQ instance for login page HTTP status code until it
      # returns 200 or specified time has elapsed
      while response != '200'
        begin
          response = Net::HTTP.get_response(uri).code
        rescue Errno::ECONNREFUSED
          Chef::Log.debug('Connection has been refused when trying to send '\
                          "GET #{uri} request")
        end
        sleep(5)
        time_diff = Time.now - start_time
        abort "Aborting since #{daemon_name} "\
              'start took more than '\
              "#{timeout / 60} minutes " if time_diff > timeout
      end

      Chef::Log.info("CQ start time: #{time_diff} seconds")
    end
  end
end
