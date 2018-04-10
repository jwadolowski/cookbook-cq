#
# Cookbook Name:: cq
# Attributes:: publish
#
# Copyright (C) 2018 Jakub Wadolowski
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

# CQ publish attributes
default['cq']['publish']['run_mode'] = 'publish'
default['cq']['publish']['port'] = '4503'
default['cq']['publish']['jmx_ip'] = ''
default['cq']['publish']['jmx_port'] = ''
default['cq']['publish']['debug_ip'] = ''
default['cq']['publish']['debug_port'] = ''
default['cq']['publish']['credentials']['login'] = 'admin'
default['cq']['publish']['credentials']['password'] = 'admin'
default['cq']['publish']['jvm']['min_heap'] = '256'
default['cq']['publish']['jvm']['max_heap'] = '1024'
default['cq']['publish']['jvm']['max_perm_size'] = '320'
default['cq']['publish']['jvm']['code_cache_size'] = '64'
default['cq']['publish']['jvm']['general_opts'] =
  '-server -Djava.awt.headless=true -Djava.net.preferIPv4Stack=true'
default['cq']['publish']['jvm']['code_cache_opts'] = ''
default['cq']['publish']['jvm']['gc_opts'] = ''
default['cq']['publish']['jvm']['jmx_opts'] = ''
default['cq']['publish']['jvm']['debug_opts'] = ''
default['cq']['publish']['jvm']['crx_opts'] = ''
default['cq']['publish']['jvm']['extra_opts'] = ''
default['cq']['publish']['healthcheck']['resource'] =
  '/libs/granite/core/content/login.html'
default['cq']['publish']['healthcheck']['response_code'] = '200'
