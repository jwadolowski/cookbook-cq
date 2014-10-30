#
# Cookbook Name:: cq
# Recipe:: commons
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

include_recipe 'chef-sugar::default'

# Set healtcheck endpoints based on CQ/AEM version
if constraint('>= 5.6.0').satisfied_by?(node['cq']['version'])
  node.default['cq']['healthcheck_resource'] =
    '/libs/granite/core/content/login.html'
elsif constraint('~> 5.5.0').satisfied_by?(node['cq']['version'])
  node.default['cq']['healthcheck_resource'] =
    '/libs/cq/core/content/login.html'
end

# Create base directory if necessary
# -----------------------------------------------------------------------------
directory node['cq']['base_dir'] do
  owner 'root'
  group 'root'
  mode '0755'
  recursive true
  action :create
end

# Create dedicated user and group
# -----------------------------------------------------------------------------
# Create group
group node['cq']['group'] do
  system true
  action :create
end

# Create user
user node['cq']['user'] do
  supports :manage_home => true
  system true
  comment 'Adobe CQ'
  group node['cq']['group']
  home node['cq']['home_dir']
  shell '/bin/bash'
  action :create
end

# Fix home directory permissions
directory node['cq']['home_dir'] do
  owner node['cq']['user']
  group node['cq']['group']
  mode '0755'
  action :create
end

# Set user limits
# -----------------------------------------------------------------------------
user_ulimit node['cq']['user'] do
  filehandle_limit node['cq']['limits']['file_descriptors']
end

# Create custom tmp directory
# -----------------------------------------------------------------------------
directory node['cq']['custom_tmp_dir'] do
  owner node['cq']['user']
  group node['cq']['group']
  mode '0755'
  action :create
  recursive true

  only_if do
    !node['cq']['custom_tmp_dir'].nil? &&
    !node['cq']['custom_tmp_dir'].empty? &&
    node['cq']['custom_tmp_dir'] != '/tmp'
  end
end

# Java deployment (JDK7 for 5.6.0+, JDK6 for any previous version)
# -----------------------------------------------------------------------------
if constraint('>= 5.6.0').satisfied_by?(node['cq']['version'])
  node.default['java']['jdk_version'] = '7'
else
  node.default['java']['jdk_version'] = '6'
end

include_recipe 'java'

# CQ Unix Toolkit installation
# -----------------------------------------------------------------------------
include_recipe 'cq-unix-toolkit'
