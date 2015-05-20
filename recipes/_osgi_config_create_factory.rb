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
  'This is a test recipe and should not be used outside of test kitchen!'
)

# Factory configurations
# -----------------------------------------------------------------------------
# *** existing: 0, append: [0,1], valid: [0,1]
osgi_config_wrapper 'com.example.random.factory' do
  properties('val1' => 'key1', 'abcd' => 'efgh')
  factory true
end
# *** existing: 1, append: 0, valid: 0
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
end
# *** existing: 1, append: 0, valid: 1
# *** existing: 1, append: 1, valid: 0
# *** existing: 1, append: 1, valid: 1
