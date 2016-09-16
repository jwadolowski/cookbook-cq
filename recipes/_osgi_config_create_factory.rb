#
# Cookbook Name:: cq
# Recipe:: _osgi_config_create_factory
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

# Factory configurations
# -----------------------------------------------------------------------------
# *** append: 0, valid: 0
osgi_config_wrapper 'com.adobe.granite.monitoring.impl.ScriptConfigImpl' do
  properties(
    'script.filename' => 'test-script.sh',
    'script.display' => 'Fancy Script',
    'script.path' => '/path/to/not/exisitng/script.sh',
    'script.platform' => ['dev7',
                          'prod1',
                          '-platform1',
                          '-p aaa',
                          '-uat17',
                          '-u bbb',
                          '-v111',
                          '-v ccc',
                          '-f36',
                          '-f ddd',
                          '-i43',
                          '-i eee',
                          '-stg1',
                          '-s ffff'],
    'interval' => '99',
    'jmxdomain' => 'com.example.monitoring'
  )
  factory true
  append false
end

osgi_config_wrapper 'com.adobe.cq.social.datastore.as.impl.'\
  'UGCCResourceProviderFactory' do
  properties(
    'version.id' => 'v1',
    'cache.on' => 'true',
    'cache.ttl' => '1000'
  )
  factory true
  unique_fields ['version.id', 'cache.on']
  count 3
  enforce_count true
  append false
end
# *** append: 0, valid: 1
osgi_config_wrapper 'com.day.cq.mcm.impl.MCMConfiguration' do
  properties(
    'experience.indirection' => %w(geometrixx/components/newsletterpage
                                   mcm/components/newsletter/page),
    'touchpoint.indirection' => %w(exampleGeometrixxAddedComp
                                   exampleMCMSuperTouchpoint),
    'extraProperty' => %w(a b c)
  )
  factory true
  append false
end
# *** append: 1, valid: 0
osgi_config_wrapper 'com.adobe.granite.auth.oauth.provider' do
  properties(
    'oauth.config.id' => 'test123'
  )
  factory true
  append true
end
# *** append: 1, valid: 1
osgi_config_wrapper 'org.apache.sling.commons.log.LogManager.factory.config' do
  properties(
    'org.apache.sling.commons.log.level' => 'info',
    'org.apache.sling.commons.log.file' => 'logs/upgrade.log',
    'org.apache.sling.commons.log.pattern' =>
      '{0,date,dd.MM.yyyy HH:mm:ss.SSS} *{4}* [{2}] {3} {5}',
    'org.apache.sling.commons.log.names' => [
      'com.day.cq.compat.codeupgrade',
      'com.adobe.cq.upgradesexecutor'
    ]
  )
  factory true
  unique_fields ['org.apache.sling.commons.log.file']
  append true
end
