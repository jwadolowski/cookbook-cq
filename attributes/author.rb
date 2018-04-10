#
# Cookbook Name:: cq
# Attributes:: author
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

# CQ author attributes
default['cq']['author']['run_mode'] = 'author'
default['cq']['author']['port'] = '4502'
default['cq']['author']['jmx_ip'] = ''
default['cq']['author']['jmx_port'] = ''
default['cq']['author']['debug_ip'] = ''
default['cq']['author']['debug_port'] = ''
default['cq']['author']['credentials']['login'] = 'admin'
default['cq']['author']['credentials']['password'] = 'admin'
default['cq']['author']['jvm']['min_heap'] = '256'
default['cq']['author']['jvm']['max_heap'] = '1024'
default['cq']['author']['jvm']['max_perm_size'] = '320'
default['cq']['author']['jvm']['code_cache_size'] = '64'
default['cq']['author']['jvm']['general_opts'] =
  '-server -Djava.awt.headless=true -Djava.net.preferIPv4Stack=true'
default['cq']['author']['jvm']['code_cache_opts'] = ''
default['cq']['author']['jvm']['gc_opts'] = ''
default['cq']['author']['jvm']['jmx_opts'] = ''
default['cq']['author']['jvm']['debug_opts'] = ''
default['cq']['author']['jvm']['crx_opts'] = ''
default['cq']['author']['jvm']['extra_opts'] = ''
default['cq']['author']['healthcheck']['resource'] =
  '/libs/granite/core/content/login.html'
default['cq']['author']['healthcheck']['response_code'] = '200'
