#
# Cookbook:: cq
# Resource:: instance
#
# Copyright:: (C) 2018 Jakub Wadolowski
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

provides :cq_instance

property :id, String, default: 'author'

action_class do
  def instance_home
    cq_instance_home(node['cq']['home_dir'], new_resource.id)
  end

  def instance_conf_dir
    cq_instance_conf_dir(node['cq']['home_dir'], new_resource.id)
  end

  def jar_name
    cq_jarfile(node['cq']['jar']['url'])
  end

  def daemon_name
    cq_daemon_name(new_resource.id)
  end
end

action :install do
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

    only_if { rhel7? || rhel8? || amazon_linux? }

    notifies :run, "execute[systemd-verify-#{daemon_name}]", :immediately
    notifies :run, 'execute[systemd-reload]', :immediately
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
  # If node['cq'][new_resource.id]['run_mode'] is set in a recipe that's
  # included after cq::author then nothing happens as template resource gets
  # compiled and all variables are already populated. With lazy evaluation user
  # can do all required amendments in compile phase and these changes will be
  # propagated correctly during converge phase.
  # ---------------------------------------------------------------------------
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
          port: node['cq'][new_resource.id]['port'],
          run_mode: node['cq'][new_resource.id]['run_mode'],
          fd_limit: node['cq']['limits']['file_descriptors'],
          instance_home: instance_home,
          min_heap: node['cq'][new_resource.id]['jvm']['min_heap'],
          max_heap: node['cq'][new_resource.id]['jvm']['max_heap'],
          jmx_ip: node['cq'][new_resource.id]['jmx_ip'],
          jmx_port: node['cq'][new_resource.id]['jmx_port'],
          debug_ip: node['cq'][new_resource.id]['debug_ip'],
          debug_port: node['cq'][new_resource.id]['debug_port'],
          tmp_dir: node['cq']['custom_tmp_dir'],
          jvm_general_opts: node['cq'][new_resource.id]['jvm']['general_opts'],
          jvm_gc_opts: node['cq'][new_resource.id]['jvm']['gc_opts'],
          jvm_jmx_opts: node['cq'][new_resource.id]['jvm']['jmx_opts'],
          jvm_debug_opts: node['cq'][new_resource.id]['jvm']['debug_opts'],
          jvm_extra_opts: node['cq'][new_resource.id]['jvm']['extra_opts'],
        }
      end
    )

    only_if { rhel7? || rhel8? || amazon_linux? }

    notifies :restart, "service[#{daemon_name}]", :immediately
    # Theoretically service restart should be enough, however notification
    # chanining does't seem to work correctly.
    #
    # Context:
    # * service resource is defined inside a recipe
    # * cq_start_guard is defined with action :nothing, as it's meant to be
    #   triggered by notfications only
    # * any service state change implies notificattion to cq_start_guard
    #   resource
    #
    # Current flow:
    # * template change sends restart to service resource
    # * service should notify cq_start_guard, but it does NOT happen (it is
    #   completely ignored)
    #
    # Expected flow:
    # * restart is always followed by cq_start_guard run
    notifies :run, "cq_start_guard[#{daemon_name}]", :immediately
  end
end
