#
# Cookbook Name:: cq
# Recipe:: _osgi_config
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

Chef::Log.warn(
  'This is a test recipe and should not be used outside of test kitchen!'
)

# * Regular (not-factory) configurations
# -----------------------------------------------------------------------------

# ** 1 key, 1 value
# *** existing: 0, append: [0,1], valid: [0,1]
cq_osgi_config 'not.existing.config.create.1k1v.1' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'key1' => 'val1'
  )

  action :create
end
# *** existing: 1, append: [0,1], valid: 0
cq_osgi_config 'com.day.cq.dam.s7dam.common.S7damDamChangeEventListener' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'cq.dam.s7dam.damchangeeventlistener.enabled' => false
  )

  action :create
end
# *** existing: 1, append: [0,1], valid: 1
cq_osgi_config 'com.day.cq.dam.scene7.impl.Scene7ConfigurationEventListener' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'cq.dam.scene7.configurationeventlistener.enabled' => true
  )

  action :create
end

# ** 1 key, N values
# *** existing: 0, append: [0,1], valid: [0,1]
cq_osgi_config 'not.existing.config.create.1kNv.1' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'key1' => ['val1', 'val2', 'val3']
  )

  action :create
end
# *** existing: 1, append: 0, valid: 0
# *** existing: 1, append: 0, valid: 1
# *** existing: 1, append: 1, valid: 0
# *** existing: 1, append: 1, valid: 1

# ** N key, N single values
# *** existing: 0, append: [0,1], valid: [0,1]
# *** existing: 1, append: 0, valid: 0
# *** existing: 1, append: 0, valid: 1
# *** existing: 1, append: 1, valid: 0
# *** existing: 1, append: 1, valid: 1

# ** N key, N complex values
# *** existing: 0, append: [0,1], valid: [0,1]
# *** existing: 1, append: 0, valid: 0
# *** existing: 1, append: 0, valid: 1
# *** existing: 1, append: 1, valid: 0
# *** existing: 1, append: 1, valid: 1

# Factory configurations
# -----------------------------------------------------------------------------

# ** 1 key, 1 value
# *** existing: 0, append: 0, valid: 0
# *** existing: 0, append: 0, valid: 1
# *** existing: 0, append: 1, valid: 0
# *** existing: 0, append: 1, valid: 1
# *** existing: 1, append: 0, valid: 0
# *** existing: 1, append: 0, valid: 1
# *** existing: 1, append: 1, valid: 0
# *** existing: 1, append: 1, valid: 1

# ** 1 key, N values
# *** existing: 0, append: 0, valid: 0
# *** existing: 0, append: 0, valid: 1
# *** existing: 0, append: 1, valid: 0
# *** existing: 0, append: 1, valid: 1
# *** existing: 1, append: 0, valid: 0
# *** existing: 1, append: 0, valid: 1
# *** existing: 1, append: 1, valid: 0
# *** existing: 1, append: 1, valid: 1

# ** N key, N single values
# *** existing: 0, append: 0, valid: 0
# *** existing: 0, append: 0, valid: 1
# *** existing: 0, append: 1, valid: 0
# *** existing: 0, append: 1, valid: 1
# *** existing: 1, append: 0, valid: 0
# *** existing: 1, append: 0, valid: 1
# *** existing: 1, append: 1, valid: 0
# *** existing: 1, append: 1, valid: 1

# ** N key, N complex values
# *** existing: 0, append: 0, valid: 0
# *** existing: 0, append: 0, valid: 1
# *** existing: 0, append: 1, valid: 0
# *** existing: 0, append: 1, valid: 1
# *** existing: 1, append: 0, valid: 0
# *** existing: 1, append: 0, valid: 1
# *** existing: 1, append: 1, valid: 0
# *** existing: 1, append: 1, valid: 1
