# ~FC015
#
# Cookbook Name:: cq
# Definition:: instance
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

define :cq_instance,
       :mode => nil do

  # Helpers
  # ---------------------------------------------------------------------------
  local_mode = params[:mode]
  instance_home = cq_instance_home(node['cq']['home_dir'], local_mode)
  instance_conf_dir = cq_instance_conf_dir(node['cq']['home_dir'], local_mode)
  jar_name = cq_jarfile(node['cq']['jar']['url'])
  daemon_name = cq_daemon_name(local_mode)

  # Create CQ instance directory
  # ---------------------------------------------------------------------------
  directory instance_home do
    owner node['cq']['user']
    group node['cq']['group']
    mode '0755'
    action :create
  end

  # Download and unpack CQ JAR file
  # ---------------------------------------------------------------------------
  # Download JAR file
  remote_file "#{instance_home}/#{jar_name}" do
    owner node['cq']['user']
    group node['cq']['group']
    mode '0644'
    source node['cq']['jar']['url']
    checksum node['cq']['jar']['checksum']
  end

  # Unpack CQ JAR file once downloaded
  bash 'Unpack CQ JAR file' do
    user node['cq']['user']
    group node['cq']['group']
    cwd instance_home
    code "java -jar #{jar_name} -unpack"
    action :run

    # Do not unpack if crx-quickstart exists inside CQ instance home
    not_if { ::Dir.exist?("#{instance_home}/crx-quickstart") }
  end

  # Deploy CQ license file
  # ---------------------------------------------------------------------------
  remote_file "#{instance_home}/license.properties" do
    owner node['cq']['user']
    group node['cq']['group']
    mode '0644'
    source node['cq']['license']['url']
    checksum node['cq']['license']['checksum']
  end

  # Create config directory
  # TODO: does it really needed? crx-quickstart/conf exists after unpack
  # ---------------------------------------------------------------------------
  directory instance_conf_dir do
    owner node['cq']['user']
    group node['cq']['group']
    mode '0755'
    action :create
  end

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

  # Render CQ config file
  # ---------------------------------------------------------------------------
  template "#{instance_conf_dir}/cq#{cq_version('short_squeezed')}"\
           "-#{local_mode}.conf" do
    owner node['cq']['user']
    group node['cq']['group']
    mode '0644'
    source 'cq.conf.erb'
    variables(
      :port => node['cq'][local_mode]['port'],
      :instance_home => instance_home,
      :mode => local_mode,
      :min_heap => node['cq'][local_mode]['jvm']['min_heap'],
      :max_heap => node['cq'][local_mode]['jvm']['max_heap'],
      :max_perm_size => node['cq'][local_mode]['jvm']['max_perm_size'],
      :code_cache => node['cq'][local_mode]['jvm']['code_cache_size'],
      :jvm_general_opts => node['cq'][local_mode]['jvm']['general_opts'],
      :jvm_code_cache_opts => node['cq'][local_mode]['jvm']['code_cache_opts'],
      :jvm_gc_opts => node['cq'][local_mode]['jvm']['gc_opts'],
      :jvm_jmx_opts => node['cq'][local_mode]['jvm']['jmx_opts'],
      :jvm_debug_opts => node['cq'][local_mode]['jvm']['debug_opts'],
      :jvm_extra_opts => node['cq'][local_mode]['jvm']['extra_opts']
    )

    notifies :restart,
      "service[cq#{cq_version('short_squeezed')}-#{local_mode}]", :immediately
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
      if constraint('>= 5.6.0').satisfied_by?(node['cq']['version'])
        uri = URI.parse("http://localhost:#{node['cq'][local_mode]['port']}"\
                        '/libs/granite/core/content/login.html')
      elsif constraint('~> 5.5.0').satisfied_by?(node['cq']['version'])
        uri = URI.parse("http://localhost:#{node['cq'][local_mode]['port']}"\
                        '/libs/cq/core/content/login.html')
      end

      # Start timeout (30 min)
      timeout = 1800

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
