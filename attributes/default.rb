#
# Cookbook Name:: cq
# Attributes:: default
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

# CQ attributes
# -----------------------------------------------------------------------------
default['cq']['user'] = 'cq'
default['cq']['user_uid'] = nil
default['cq']['user_comment'] = 'Adobe CQ'
default['cq']['user_shell'] = '/bin/bash'
default['cq']['group'] = 'cq'
default['cq']['group_gid'] = nil
default['cq']['limits']['file_descriptors'] = '16384'
default['cq']['base_dir'] = '/opt'
default['cq']['home_dir'] = "#{node['cq']['base_dir']}/cq"
default['cq']['version'] = '5.6.1'
default['cq']['custom_tmp_dir'] = '/opt/tmp'
default['cq']['jar']['url'] = nil
default['cq']['jar']['checksum'] = nil
default['cq']['license']['url'] = nil
default['cq']['license']['checksum'] = nil

default['cq']['service']['start_timeout'] = 1800
default['cq']['service']['kill_delay'] = 120
default['cq']['service']['restart_sleep'] = 5

default['cq']['init_template_cookbook'] = 'cq'
default['cq']['systemd_template_cookbook'] = 'cq'
default['cq']['conf_template_cookbook'] = 'cq'

default['cq']['http_read_timeout'] = 300

default['cq']['crypto']['log_libs']['server'] = 'http://central.maven.org'
default['cq']['crypto']['log_libs']['data'] = {
  '/maven2/org/slf4j/slf4j-api/1.7.12/slf4j-api-1.7.12.jar' =>
    '0aee9a77a4940d72932b0d0d9557793f872e66a03f598e473f45e7efecdccf99',
  '/maven2/org/slf4j/slf4j-simple/1.7.12/slf4j-simple-1.7.12.jar' =>
    'ff15e390d71e9852c296fb63986995609dc8c6681f9eff45ef65281a94649acd',
}

# Java attributes
# -----------------------------------------------------------------------------
default['java']['jdk_version'] = '8'
default['java']['install_flavor'] = 'oracle'
default['java']['oracle']['accept_oracle_download_terms'] = true
