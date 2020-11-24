#
# Cookbook:: cq
# Recipe:: publish
#
# Copyright:: (C) 2020 Jakub Wadolowski
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

include_recipe 'cq::commons'

cq_instance 'CQ Publish' do
  id 'publish'
end

# -----------------------------------------------------------------------------
# Define service resource for given cq_instance
#
# "service <daemon_name>" used to be defined within definition, so its scope
# was global (definiton acts as compile time macro). Nowadays, cq_instance is a
# custom resource, hence access to its internal (and dynamic) sub-resources is
# not possible. Since many other resourcess notify service resource (e.g. in
# order to restart AEM after CRX package deployment) it's been decided to
# preserve global character of service resource and define it here.
# -----------------------------------------------------------------------------
daemon_name = cq_daemon_name('publish')

# Start the instance if it hasn't started yet
service daemon_name do
  supports status: true, restart: true

  action [:start, :enable]

  notifies :run, "cq_start_guard[#{daemon_name}]", :immediately
end

# Wait until CQ is fully up and running
cq_start_guard daemon_name do
  instance "http://localhost:#{node['cq']['publish']['port']}"
  path node['cq']['publish']['healthcheck']['resource']
  expected_code node['cq']['publish']['healthcheck']['response_code']
  expected_body node['cq']['publish']['healthcheck']['response_body']
  timeout node['cq']['service']['start_timeout']

  action :nothing
end
