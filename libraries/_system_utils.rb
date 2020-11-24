#
# Cookbook:: cq
# Libraries:: SystemUtils
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

module Cq
  module SystemUtils
    def rhel6?
      node['platform_family'] == 'rhel' &&
        (node['platform'] == 'centos' || node['platform'] == 'redhat') &&
        node['platform_version'].to_i == 6
    end

    def rhel7?
      node['platform_family'] == 'rhel' &&
        (node['platform'] == 'centos' || node['platform'] == 'redhat') &&
        node['platform_version'].to_i == 7
    end

    def rhel8?
      node['platform_family'] == 'rhel' &&
        (node['platform'] == 'centos' || node['platform'] == 'redhat') &&
        node['platform_version'].to_i == 8
    end

    def amazon_linux1?
      node['platform_family'] == 'amazon' && node['platform'] == 'amazon' &&
        node['platform_version'].between?(2013,2018)
    end

    def amazon_linux2?
      node['platform_family'] == 'amazon' && node['platform'] == 'amazon' &&
        node['platform_version'].to_i == 2
    end
  end
end
