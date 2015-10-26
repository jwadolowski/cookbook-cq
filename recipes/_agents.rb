#
# Cookbook Name:: cq
# Recipe:: _cq_agent
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

Chef::Log.warn(
  'This is a test recipe and must not be used outside of test kitchen!'
)

cq_agent 'Author: /etc/replication/agents.author/publish' do
  path '/etc/replication/agents.author/publish'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'sling:resourceType' => 'cq/replication/components/agent',
    'jcr:title' => '2nd replication agent',
    'jcr:description' => 'Agent that replicates content to 2nd publish',
    'enabled' => false,
    'serializationType' => 'durbo',
    'retryDelay' => 60000,
    'logLevel' => 'info',
    'transportUri' =>
      'http://localhost:4503/bin/receive?sling:authRequestLogin=1',
    'transportUser' => 'admin',
    'transportPassword' => 'passw0rd'
  )

  action :modify
end

cq_agent 'Author: /etc/replication/agents.author/publish2' do
  path '/etc/replication/agents.author/publish2'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'sling:resourceType' => 'cq/replication/components/agent',
    'jcr:title' => '2nd replication agent',
    'jcr:description' => 'Agent that replicates content to 2nd publish',
    'enabled' => false,
    'serializationType' => 'durbo',
    'retryDelay' => 60000,
    'logLevel' => 'info',
    'transportUri' =>
      'http://publish2:4503/bin/receive?sling:authRequestLogin=1',
    'transportUser' => 'admin',
    'transportPassword' => 'PUB2_passw0rd'
  )

  action :create
end
