#
# Cookbook Name:: cq
# Libraries:: OsgiHelper
#
# Copyright (C) 2016 Jakub Wadolowski
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
  module OsgiHelper
    include Cq::HttpHelper

    def bundle_list(addr, user, password)
      json_to_hash(
        http_get(addr, '/system/console/bundles/.json', user, password).body
      )
    end

    # symbolicName is unique, hence filtering using .detect
    def bundle_info(addr, user, password, bundle_name)
      bundle_list(addr, user, password)['data'].detect do |b|
        b['symbolicName'] == bundle_name
      end
    end

    # Executes defined operation on given bundle ID
    def bundle_op(addr, user, password, id, op)
      req_path = "/system/console/bundles/#{id}"
      payload = {
        'action' => op
      }

      http_post(addr, req_path, user, password, payload)
    end
  end
end
