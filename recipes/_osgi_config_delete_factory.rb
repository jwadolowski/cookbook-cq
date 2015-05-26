#
# Cookbook Name:: cq
# Recipe:: _osgi_config_delete_factory
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
  'This is a test recipe and should not be used outside of test kitchen!'
)

osgi_config_wrapper 'not.existing.factory.config.to.delete' do
  properties('x' => '123')
  factory true
  action :delete
end

osgi_config_wrapper 'org.apache.sling.tenant.internal.TenantProviderImpl' do
  properties(
    'tenant.root' => '/some/path',
    'tenant.path.matcher' => ['/home/a*', '/home/b*']
  )
  factory true
  force true
  action :delete
end

osgi_config_wrapper 'org.apache.sling.commons.log.LogManager.factory.writer' do
  properties(
    'org.apache.sling.commons.log.file' => 'logs/custom.log',
    'org.apache.sling.commons.log.file.number' => 10,
    'org.apache.sling.commons.log.file.size' => "'.'yyyy-MM-dd"
  )
  factory true
  action :delete
end

osgi_config_wrapper 'org.apache.sling.event.jobs.QueueConfiguration' do
  properties(
    'queue.name' => 'Granite Workflow Timeout Queue',
    'queue.type' => 'TOPIC_ROUND_ROBIN',
    'queue.topics' => ['com/adobe/granite/workflow/timeout/job'],
    'queue.maxparallel' => -1,
    'queue.retries' => 10,
    'queue.retrydelay' => 2000,
    'queue.priority' => 'MIN',
    'service.ranking' => 0
  )
  factory true
  action :delete
end
