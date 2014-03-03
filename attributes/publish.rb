#
# Cookbook Name:: cq
# Attributes:: publish
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

# CQ publish attributes
default[:cq][:publish][:mode] = 'publish'
default[:cq][:publish][:port] = '4503'
default[:cq][:publish][:jvm][:min_heap] = '512'
default[:cq][:publish][:jvm][:max_heap] = '1024'
default[:cq][:publish][:jvm][:max_perm_size] = '128'
