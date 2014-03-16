# ~FC015
#
# Cookbook Name:: cq
# Definition:: installer
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

require 'pathname'
require 'uri'

define :cq_installer,
       :mode => nil do

  # Helpers
  # ---------------------------------------------------------------------------
  instance_home = "#{node[:cq][:home_dir]}/#{params[:mode]}"
  instance_conf_dir = "#{instance_home}/conf"
  cq_short_ver = node[:cq][:version].to_s.delete('^0-9')[0, 2]
  jar_name = Pathname.new(URI.parse(node[:cq][:jar][:url]).path).basename.to_s

  # Create custom tmp directory
  # ---------------------------------------------------------------------------
  log "CQ TMPDIR = #{node[:cq][params[:mode]][:custom_tmp_dir].nil?}" do
    level :debug
  end
  if !node[:cq][params[:mode]][:custom_tmp_dir].nil? &&
     !node[:cq][params[:mode]][:custom_tmp_dir].empty? &&
     !node[:cq][params[:mode]][:custom_tmp_dir] == '/tmp'
    directory node[:cq][params[:mode]][:custom_tmp_dir] do
      owner node[:cq][:user]
      group node[:cq][:group]
      mode '0755'
      action :create
    end
  end

  # Create CQ instance directory
  # ---------------------------------------------------------------------------
  directory instance_home do
    owner node[:cq][:user]
    group node[:cq][:group]
    mode '0755'
    action :create
  end

  # Download and unpack CQ JAR file
  # ---------------------------------------------------------------------------
  # Download JAR file
  remote_file "#{instance_home}/#{jar_name}" do
    owner node[:cq][:user]
    group node[:cq][:group]
    mode '0644'
    source node[:cq][:jar][:url]
    checksum node[:cq][:jar][:checksum]
  end

  # Unpack CQ JAR file once downloaded
  bash 'Unpack CQ JAR file' do
    user node[:cq][:user]
    group node[:cq][:group]
    cwd instance_home
    code "java -jar #{jar_name} -unpack"
    action :run

    # Do not unpack if crx-quickstart exists inside CQ instance home
    not_if { ::Dir.exist?("#{instance_home}/crx-quickstart") }
  end

  # Deploy CQ license file
  # ---------------------------------------------------------------------------
  remote_file "#{instance_home}/license.properties" do
    owner node[:cq][:user]
    group node[:cq][:group]
    mode '0644'
    source node[:cq][:license][:url]
    checksum node[:cq][:license][:checksum]
  end

  # Install configuration file
  # ---------------------------------------------------------------------------
  # Create config directory
  directory instance_conf_dir do
    owner node[:cq][:user]
    group node[:cq][:group]
    mode '0755'
    action :create
  end

  # Render CQ config file
  template "#{instance_conf_dir}/cq#{cq_short_ver}-#{params[:mode]}.conf" do
    owner node[:cq][:user]
    group node[:cq][:group]
    mode '0644'
    source 'cq.conf.erb'
    variables(
      :port => node[:cq][params[:mode]][:port],
      :instance_home => instance_home,
      :mode => params[:mode],
      :min_heap => node[:cq][params[:mode]][:jvm][:min_heap],
      :max_heap => node[:cq][params[:mode]][:jvm][:max_heap],
      :max_perm_size => node[:cq][params[:mode]][:jvm][:max_perm_size],
      :code_cache => node[:cq][params[:mode]][:jvm][:code_cache_size],
      :jvm_general_opts => node[:cq][params[:mode]][:jvm][:general_opts],
      :jvm_code_cache_opts => node[:cq][params[:mode]][:jvm][:code_cache_opts],
      :jvm_gc_opts => node[:cq][params[:mode]][:jvm][:gc_opts],
      :jvm_jmx_opts => node[:cq][params[:mode]][:jvm][:jmx_opts],
      :jvm_debug_opts => node[:cq][params[:mode]][:jvm][:debug_opts],
      :jvm_extra_opts => node[:cq][params[:mode]][:jvm][:extra_opts]
    )
  end
end
