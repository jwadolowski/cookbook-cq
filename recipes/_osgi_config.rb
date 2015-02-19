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

Chef::Log.info(
  'This is a test recipe and should not be used outside of test kitchen!'
)

# * Regular (not-factory) configurations
# -----------------------------------------------------------------------------

# ** Create action
# -------------

# *** 1 key, 1 value
# **** existing: 0, append: [0,1], valid: [0,1]
cq_osgi_config 'not.existing.config.create.1k1v.1' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'key1' => 'val1',
  )

  action :create
end
# **** existing: 1, append: [0,1], valid: 0
cq_osgi_config 'com.day.cq.dam.s7dam.common.S7damDamChangeEventListener' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'cq.dam.s7dam.damchangeeventlistener.enabled' => false,
  )

  action :create
end
# **** existing: 1, append: [0,1], valid: 1
cq_osgi_config 'com.day.cq.dam.scene7.impl.Scene7ConfigurationEventListener' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'cq.dam.scene7.configurationeventlistener.enabled' => true,
  )

  action :create
end

# *** 1 key, N values
# **** existing: 0, append: [0,1], valid: [0,1]
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

# *** N key, N single values
# **** existing: 0, append: [0,1], valid: [0,1]
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

# *** N key, N comples values
# **** existing: 0, append: [0,1], valid: [0,1]
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

# Delete action
# -------------

# *** 1 key, 1 value
# **** existing: 0, append: 0, valid: 0
# **** existing: 0, append: 0, valid: 1
# **** existing: 0, append: 1, valid: 0
# **** existing: 0, append: 1, valid: 1
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

# *** 1 key, N values
# **** existing: 0, append: 0, valid: 0
# **** existing: 0, append: 0, valid: 1
# **** existing: 0, append: 1, valid: 0
# **** existing: 0, append: 1, valid: 1
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

# *** N key, N single values
# **** existing: 0, append: 0, valid: 0
# **** existing: 0, append: 0, valid: 1
# **** existing: 0, append: 1, valid: 0
# **** existing: 0, append: 1, valid: 1
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

# *** N key, N comples values
# **** existing: 0, append: 0, valid: 0
# **** existing: 0, append: 0, valid: 1
# **** existing: 0, append: 1, valid: 0
# **** existing: 0, append: 1, valid: 1
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

# Modify action
# -------------

# *** 1 key, 1 value
# **** existing: 0, append: 0, valid: 0
# **** existing: 0, append: 0, valid: 1
# **** existing: 0, append: 1, valid: 0
# **** existing: 0, append: 1, valid: 1
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

# *** 1 key, N values
# **** existing: 0, append: 0, valid: 0
# **** existing: 0, append: 0, valid: 1
# **** existing: 0, append: 1, valid: 0
# **** existing: 0, append: 1, valid: 1
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

# *** N key, N single values
# **** existing: 0, append: 0, valid: 0
# **** existing: 0, append: 0, valid: 1
# **** existing: 0, append: 1, valid: 0
# **** existing: 0, append: 1, valid: 1
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

# *** N key, N comples values
# **** existing: 0, append: 0, valid: 0
# **** existing: 0, append: 0, valid: 1
# **** existing: 0, append: 1, valid: 0
# **** existing: 0, append: 1, valid: 1
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

# Manage action
# -------------

# *** 1 key, 1 value
# **** existing: 0, append: 0, valid: 0
# **** existing: 0, append: 0, valid: 1
# **** existing: 0, append: 1, valid: 0
# **** existing: 0, append: 1, valid: 1
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

# *** 1 key, N values
# **** existing: 0, append: 0, valid: 0
# **** existing: 0, append: 0, valid: 1
# **** existing: 0, append: 1, valid: 0
# **** existing: 0, append: 1, valid: 1
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

# *** N key, N single values
# **** existing: 0, append: 0, valid: 0
# **** existing: 0, append: 0, valid: 1
# **** existing: 0, append: 1, valid: 0
# **** existing: 0, append: 1, valid: 1
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

# *** N key, N comples values
# **** existing: 0, append: 0, valid: 0
# **** existing: 0, append: 0, valid: 1
# **** existing: 0, append: 1, valid: 0
# **** existing: 0, append: 1, valid: 1
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

# Factory configurations
# -----------------------------------------------------------------------------

# Create action
# -------------

# *** 1 key, 1 value
# **** existing: 0, append: 0, valid: 0
# **** existing: 0, append: 0, valid: 1
# **** existing: 0, append: 1, valid: 0
# **** existing: 0, append: 1, valid: 1
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

# *** 1 key, N values
# **** existing: 0, append: 0, valid: 0
# **** existing: 0, append: 0, valid: 1
# **** existing: 0, append: 1, valid: 0
# **** existing: 0, append: 1, valid: 1
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

# *** N key, N single values
# **** existing: 0, append: 0, valid: 0
# **** existing: 0, append: 0, valid: 1
# **** existing: 0, append: 1, valid: 0
# **** existing: 0, append: 1, valid: 1
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

# *** N key, N comples values
# **** existing: 0, append: 0, valid: 0
# **** existing: 0, append: 0, valid: 1
# **** existing: 0, append: 1, valid: 0
# **** existing: 0, append: 1, valid: 1
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

# Delete action
# -------------

# *** 1 key, 1 value
# **** existing: 0, append: 0, valid: 0
# **** existing: 0, append: 0, valid: 1
# **** existing: 0, append: 1, valid: 0
# **** existing: 0, append: 1, valid: 1
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

# *** 1 key, N values
# **** existing: 0, append: 0, valid: 0
# **** existing: 0, append: 0, valid: 1
# **** existing: 0, append: 1, valid: 0
# **** existing: 0, append: 1, valid: 1
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

# *** N key, N single values
# **** existing: 0, append: 0, valid: 0
# **** existing: 0, append: 0, valid: 1
# **** existing: 0, append: 1, valid: 0
# **** existing: 0, append: 1, valid: 1
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

# *** N key, N comples values
# **** existing: 0, append: 0, valid: 0
# **** existing: 0, append: 0, valid: 1
# **** existing: 0, append: 1, valid: 0
# **** existing: 0, append: 1, valid: 1
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

# Modify action
# -------------

# *** 1 key, 1 value
# **** existing: 0, append: 0, valid: 0
# **** existing: 0, append: 0, valid: 1
# **** existing: 0, append: 1, valid: 0
# **** existing: 0, append: 1, valid: 1
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

# *** 1 key, N values
# **** existing: 0, append: 0, valid: 0
# **** existing: 0, append: 0, valid: 1
# **** existing: 0, append: 1, valid: 0
# **** existing: 0, append: 1, valid: 1
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

# *** N key, N single values
# **** existing: 0, append: 0, valid: 0
# **** existing: 0, append: 0, valid: 1
# **** existing: 0, append: 1, valid: 0
# **** existing: 0, append: 1, valid: 1
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

# *** N key, N comples values
# **** existing: 0, append: 0, valid: 0
# **** existing: 0, append: 0, valid: 1
# **** existing: 0, append: 1, valid: 0
# **** existing: 0, append: 1, valid: 1
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

# Manage action
# -------------
# *** 1 key, 1 value
# **** existing: 0, append: 0, valid: 0
# **** existing: 0, append: 0, valid: 1
# **** existing: 0, append: 1, valid: 0
# **** existing: 0, append: 1, valid: 1
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

# *** 1 key, N values
# **** existing: 0, append: 0, valid: 0
# **** existing: 0, append: 0, valid: 1
# **** existing: 0, append: 1, valid: 0
# **** existing: 0, append: 1, valid: 1
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

# *** N key, N single values
# **** existing: 0, append: 0, valid: 0
# **** existing: 0, append: 0, valid: 1
# **** existing: 0, append: 1, valid: 0
# **** existing: 0, append: 1, valid: 1
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

# *** N key, N comples values
# **** existing: 0, append: 0, valid: 0
# **** existing: 0, append: 0, valid: 1
# **** existing: 0, append: 1, valid: 0
# **** existing: 0, append: 1, valid: 1
# **** existing: 1, append: 0, valid: 0
# **** existing: 1, append: 0, valid: 1
# **** existing: 1, append: 1, valid: 0
# **** existing: 1, append: 1, valid: 1

















# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------
# -----------------------------------------------------------------------------

# # Not existing OSGi config
# cq_osgi_config 'not.existing.osgi.config' do
#   username node['cq']['author']['credentials']['login']
#   password node['cq']['author']['credentials']['password']
#   instance "http://localhost:#{node['cq']['author']['port']}"
#   properties(
#     'val1' => 'true',
#     'val2' => 'false'
#   )

#   action :create
# end

# # 1 key, mulitple values
# cq_osgi_config 'org.apache.sling.commons.mime.internal.MimeTypeServiceImpl' do
#   username node['cq']['author']['credentials']['login']
#   password node['cq']['author']['credentials']['password']
#   instance "http://localhost:#{node['cq']['author']['port']}"
#   properties(
#     'mime.types' => ['text/html html',
#                      'application/json json',
#                      'text/css css']
#   )

#   action :create
# end

# # 1 key, mulitple values (append)
# cq_osgi_config 'com.day.cq.dam.core.impl.handler.xmp.NCommXMPHandler' do
#   username node['cq']['author']['credentials']['login']
#   password node['cq']['author']['credentials']['password']
#   instance "http://localhost:#{node['cq']['author']['port']}"
#   # append true
#   # properties(
#   #   'xmphandler.cq.formats' => ['image/xyz',
#   #                               'image/abcd']
#   # )
#   properties(
#     'xmphandler.cq.formats' => ['']
#   )

#   action :create
# end

# # 1 key, 1 value
# cq_osgi_config 'com.day.cq.commons.servlets.RootMappingServlet' do
#   username node['cq']['author']['credentials']['login']
#   password node['cq']['author']['credentials']['password']
#   instance "http://localhost:#{node['cq']['author']['port']}"
#   properties('rootmapping.target' => '/welcome.html')

#   action :create
# end

# # N key, N values
# cq_osgi_config 'org.apache.sling.jcr.davex.impl.servlets.SlingDavExServlet' do
#   username node['cq']['author']['credentials']['login']
#   password node['cq']['author']['credentials']['password']
#   instance "http://localhost:#{node['cq']['author']['port']}"
#   properties(
#     'alias' => '/crx/server',
#     'dav.create-absolute-uri' => 'true'
#   )

#   action :create
# end

# # Factory config (too low score => create new)
# cq_osgi_config 'new config' do
#   username node['cq']['author']['credentials']['login']
#   password node['cq']['author']['credentials']['password']
#   instance "http://localhost:#{node['cq']['author']['port']}"
#   factory_pid 'org.apache.sling.commons.log.LogManager.factory.config'
#   append true
#   properties(
#     'org.apache.sling.commons.log.level' => 'info',
#     'org.apache.sling.commons.log.file' => 'logs/chef_factory_test.log'
#   )
# end

# # Factory config (just 1 candidate => update existing)
# cq_osgi_config 'simple config' do
#   username node['cq']['author']['credentials']['login']
#   password node['cq']['author']['credentials']['password']
#   instance "http://localhost:#{node['cq']['author']['port']}"
#   factory_pid 'org.apache.sling.commons.log.LogManager.factory.config'
#   append true
#   properties(
#     'org.apache.sling.commons.log.level' => 'info',
#     'org.apache.sling.commons.log.file' => 'logs/audit.log'
#   )
# end

# # Factory config (more than 1 candidate)
# cq_osgi_config 'simple config' do
#   username node['cq']['author']['credentials']['login']
#   password node['cq']['author']['credentials']['password']
#   instance "http://localhost:#{node['cq']['author']['port']}"
#   factory_pid 'org.apache.sling.commons.log.LogManager'
#   properties(
#     'org.apache.sling.commons.log.level' => 'info'
#   )
# end
