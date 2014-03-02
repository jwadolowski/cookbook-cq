#
# Cookbook Name:: cq
# Attributes:: default
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

# CQ attributes
# -----------------------------------------------------------------------------
default[:cq][:user] = 'cq'
default[:cq][:group] = 'cq'
default[:cq][:limits][:file_descriptors] = '16384'
default[:cq][:base_dir] = '/opt'
default[:cq][:home_dir] = "#{node[:cq][:base_dir]}/cq"
default[:cq][:version] = '5.6.1'

# Java attributes
# -----------------------------------------------------------------------------
default[:java][:install_flavor] = 'oracle'
default[:java][:oracle][:accept_oracle_download_terms] = true

# CQ Unix Toolkit attributes
# -----------------------------------------------------------------------------
default[:cq_unix_toolkit][:repository][:revison] = '1.1-rc'
