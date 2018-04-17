# ~FC015
#
# Cookbook Name:: cq
# Definition:: instance
#
# Copyright (C) 2018 Jakub Wadolowski
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

define :cq_instance, id: nil do
  # ---------------------------------------------------------------------------
  # Helpers
  # ---------------------------------------------------------------------------
  local_id = params[:id]
  instance_home = cq_instance_home(node['cq']['home_dir'], local_id)
  instance_conf_dir = cq_instance_conf_dir(node['cq']['home_dir'], local_id)
  jar_name = cq_jarfile(node['cq']['jar']['url'])
  daemon_name = cq_daemon_name(local_id)

  Chef::Log.warn "Attribute node['cq']['#{params[:id]}']['mode'] is now "\
    'deprecated and can be safely removed.' if node['cq'][local_id]['mode']

  # ---------------------------------------------------------------------------
  # Create CQ instance directory
  # ---------------------------------------------------------------------------
  directory instance_home do
    owner node['cq']['user']
    group node['cq']['group']
    mode '0755'
    action :create
  end

  # ---------------------------------------------------------------------------
  # Download and unpack CQ JAR file
  # ---------------------------------------------------------------------------

  # Download JAR file to Chef's cache
  remote_file "#{Chef::Config[:file_cache_path]}/#{jar_name}" do
    owner 'root'
    group 'root'
    mode '0644'
    source node['cq']['jar']['url']
    checksum node['cq']['jar']['checksum'] if node['cq']['jar']['checksum']

    action :create_if_missing
  end

  # Move JAR file to instance home
  remote_file "#{instance_home}/#{jar_name}" do
    owner node['cq']['user']
    group node['cq']['group']
    mode '0644'
    source "file://#{Chef::Config[:file_cache_path]}/#{jar_name}"
    checksum node['cq']['jar']['checksum'] if node['cq']['jar']['checksum']

    action :create_if_missing
  end

  # Unpack CQ JAR file once downloaded
  bash "Unpack #{instance_home}/#{jar_name} file" do
    user node['cq']['user']
    group node['cq']['group']
    cwd instance_home
    code "java -jar #{jar_name} -unpack"
    action :run

    # Do not unpack if crx-quickstart exists inside CQ instance home
    not_if { ::Dir.exist?("#{instance_home}/crx-quickstart") }
  end

  # ---------------------------------------------------------------------------
  # Deploy CQ license file
  # ---------------------------------------------------------------------------
  # Download license file to Chef's cache
  remote_file "#{Chef::Config[:file_cache_path]}/license.properties" do
    owner 'root'
    group 'root'
    mode '0644'
    source node['cq']['license']['url']
    checksum node['cq']['license']['checksum'] if
      node['cq']['license']['checksum']
  end

  # Move license to instance home
  remote_file "#{instance_home}/license.properties" do
    owner node['cq']['user']
    group node['cq']['group']
    mode '0644'
    source "file://#{Chef::Config[:file_cache_path]}/license.properties"
    checksum node['cq']['license']['checksum'] if
      node['cq']['license']['checksum']
  end

  # ---------------------------------------------------------------------------
  # Render SysVinit start script
  # ---------------------------------------------------------------------------
  template "/etc/init.d/#{daemon_name}" do
    extend Cq::SystemUtils

    owner 'root'
    group 'root'
    mode '0755'
    cookbook node['cq']['init_template_cookbook']
    source 'etc/init.d/cq.init.erb'
    variables(
      daemon_name: daemon_name,
      full_name: "Adobe CQ #{node['cq']['version']} " +
                 local_id.to_s.capitalize,
      conf_file: ::File.join(instance_conf_dir, "#{daemon_name}.conf"),
      kill_delay: node['cq']['service']['kill_delay'],
      restart_sleep: node['cq']['service']['restart_sleep']
    )

    only_if { rhel6? }
  end

  # ---------------------------------------------------------------------------
  # Render systemd start script
  # ---------------------------------------------------------------------------
  template "/etc/systemd/system/#{daemon_name}.service" do
    extend Cq::SystemUtils

    owner 'root'
    group 'root'
    mode '0644'
    cookbook node['cq']['systemd_template_cookbook']
    source 'etc/systemd/system/cq.service.erb'
    variables(
      daemon_name: daemon_name,
      conf_file: ::File.join(instance_conf_dir, "#{daemon_name}.conf"),
      cq_home: instance_home,
      user: node['cq']['user'],
      fd_limit: node['cq']['limits']['file_descriptors']
    )

    only_if { rhel7? }

    # Delete SysVinit service before rendering systemd start script
    notifies :run, "execute[chkconfig-delete-#{daemon_name}]", :before
    notifies :run, "execute[systemd-verify-#{daemon_name}]", :immediately
    notifies :run, 'execute[systemd-reload]', :immediately
  end

  execute "chkconfig-delete-#{daemon_name}" do
    command "chkconfig --del #{daemon_name}"

    action :nothing

    only_if { ::File.exist?("/etc/init.d/#{daemon_name}") }

    notifies :delete, "file[/etc/init.d/#{daemon_name}]", :immediately
  end

  file "/etc/init.d/#{daemon_name}" do
    action :nothing
  end

  execute "systemd-verify-#{daemon_name}" do
    command "systemd-analyze verify #{daemon_name}.service"

    action :nothing
  end

  execute 'systemd-reload' do
    command 'systemctl daemon-reload'

    action :nothing
  end

  # ---------------------------------------------------------------------------
  # Render CQ config file
  #
  # All template variables are lazy evaluated to cover scenarios when one of
  # attributes i.e. run mode is set on multiple levels, including recipe.
  #
  # Example:
  # * default run mode is set in this cookbook
  # * run mode is reconfigured on environment level
  # * in a recipe user would like to append additional run mode to the one
  #   that's set on environment level
  #
  # If node['cq'][local_id]['run_mode'] is set in a recipe that's included
  # after cq::author then nothing happens as template resource gets compiled
  # and all variables are already populated. With lazy evaluation user can do
  # all required amendments in compile phase and these changes will be
  # propagated correctly during converge phase.
  # ---------------------------------------------------------------------------
  template "#{instance_conf_dir}/#{daemon_name}.conf" do
    extend Cq::SystemUtils

    owner node['cq']['user']
    group node['cq']['group']
    mode '0644'
    cookbook node['cq']['conf_template_cookbook']
    source 'cq-init.conf.erb'
    variables(
      lazy do
        {
          port: node['cq'][local_id]['port'],
          jmx_ip: node['cq'][local_id]['jmx_ip'],
          jmx_port: node['cq'][local_id]['jmx_port'],
          debug_ip: node['cq'][local_id]['debug_ip'],
          debug_port: node['cq'][local_id]['debug_port'],
          instance_home: instance_home,
          run_mode: node['cq'][local_id]['run_mode'],
          min_heap: node['cq'][local_id]['jvm']['min_heap'],
          max_heap: node['cq'][local_id]['jvm']['max_heap'],
          max_perm_size: node['cq'][local_id]['jvm']['max_perm_size'],
          code_cache: node['cq'][local_id]['jvm']['code_cache_size'],
          jvm_general_opts: node['cq'][local_id]['jvm']['general_opts'],
          jvm_code_cache_opts: node['cq'][local_id]['jvm']['code_cache_opts'],
          jvm_gc_opts: node['cq'][local_id]['jvm']['gc_opts'],
          jvm_jmx_opts: node['cq'][local_id]['jvm']['jmx_opts'],
          jvm_debug_opts: node['cq'][local_id]['jvm']['debug_opts'],
          jvm_crx_opts: node['cq'][local_id]['jvm']['crx_opts'],
          jvm_extra_opts: node['cq'][local_id]['jvm']['extra_opts'],
        }
      end
    )

    only_if { rhel6? }

    notifies :restart, "service[#{daemon_name}]", :immediately
  end

  template "#{instance_conf_dir}/#{daemon_name}.conf" do
    extend Cq::SystemUtils

    owner node['cq']['user']
    group node['cq']['group']
    mode '0644'
    cookbook node['cq']['conf_template_cookbook']
    source 'cq-systemd.conf.erb'
    variables(
      lazy do
        {
          port: node['cq'][local_id]['port'],
          run_mode: node['cq'][local_id]['run_mode'],
          fd_limit: node['cq']['limits']['file_descriptors'],
          instance_home: instance_home,
          min_heap: node['cq'][local_id]['jvm']['min_heap'],
          max_heap: node['cq'][local_id]['jvm']['max_heap'],
          jmx_ip: node['cq'][local_id]['jmx_ip'],
          jmx_port: node['cq'][local_id]['jmx_port'],
          debug_ip: node['cq'][local_id]['debug_ip'],
          debug_port: node['cq'][local_id]['debug_port'],
          tmp_dir: node['cq']['custom_tmp_dir'],
          jvm_general_opts: node['cq'][local_id]['jvm']['general_opts'],
          jvm_gc_opts: node['cq'][local_id]['jvm']['gc_opts'],
          jvm_jmx_opts: node['cq'][local_id]['jvm']['jmx_opts'],
          jvm_debug_opts: node['cq'][local_id]['jvm']['debug_opts'],
          jvm_extra_opts: node['cq'][local_id]['jvm']['extra_opts'],
        }
      end
    )

    only_if { rhel7? }

    notifies :restart, "service[#{daemon_name}]", :immediately
  end

  # ---------------------------------------------------------------------------
  # Enable & start CQ instance
  # ---------------------------------------------------------------------------
  service "#{daemon_name} (enable)" do
    service_name daemon_name
    action :enable
  end

  service daemon_name do
    supports status: true, restart: true
    action :start

    notifies :run, "ruby_block[cq-#{local_id}-start-guard]", :immediately
  end

  # ---------------------------------------------------------------------------
  # Wait until CQ is fully up and running
  # ---------------------------------------------------------------------------
  ruby_block "cq-#{local_id}-start-guard" do # ~FC014
    block do
      require 'net/http'
      require 'uri'

      # Pick valid resource to verify CQ instance full start
      uri = URI.parse(
        "http://localhost:#{node['cq'][local_id]['port']}" +
        node['cq'][local_id]['healthcheck']['resource']
      )

      # Start timeout
      start_timeout = node['cq']['service']['start_timeout']

      # Save current net read timeout value
      current_http_timeout = node['cq']['http_read_timeout']

      response = '-1'
      start_time = Time.now

      # Keep asking CQ instance for login page HTTP status code until it
      # returns 200 or specified time has elapsed
      while response != node['cq'][local_id]['healthcheck']['response_code']
        begin
          # Reduce net read time value to speed up start guard procedure
          node.default['cq']['http_read_timeout'] = 5

          response = Net::HTTP.get_response(uri).code
          Chef::Log.debug("HTTP response: #{response}")
        rescue => e
          Chef::Log.debug(
            "Error occurred while trying to send GET #{uri} request: #{e}"
          )
        ensure
          # Restore original timeout
          node.default['cq']['http_read_timeout'] = current_http_timeout
        end
        sleep(5)
        time_diff = Time.now - start_time
        Chef::Log.debug("Time elapsed since process start: #{time_diff}")
        abort "Aborting since #{daemon_name} start took more than "\
          "#{start_timeout / 60} minutes " if time_diff > start_timeout
      end

      Chef::Log.info("CQ start time: #{time_diff} seconds")
    end

    action :nothing
  end
end
