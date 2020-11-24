#
# Cookbook:: cq
# Recipe:: default
#
# Copyright:: (C) 2018 Jakub Wadolowski
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

chef_gem 'addressable' do
  compile_time false
end

chef_gem 'multipart-post' do
  compile_time false
  version '2.0.0'
end

package 'unzip'
package 'rng-tools'
