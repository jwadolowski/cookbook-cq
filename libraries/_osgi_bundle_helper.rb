#
# Cookbook Name:: cq
# Libraries:: OsgiBundleHelper
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

require_relative '_healthcheck_helper'
require_relative '_http_helper'

module Cq
  module OsgiBundleHelper
    include Cq::HealthcheckHelper
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
        'action' => op,
      }

      http_post(addr, req_path, user, password, payload)
    end

    # stateRaw:
    # * UNINSTALLED = 1
    # * INSTALLED   = 2
    # * RESOLVED    = 4
    # * STARTING    = 8
    # * STOPPING    = 16
    # * ACTIVE      = 32
    #
    # Response body: {"fragment":false,"stateRaw":32}
    #
    # Expected:
    # * 200 HTTP status code
    # * fragment equals false
    # * stateRaws as defined
    def valid_bundle_op?(http_resp, expected_state)
      return false if http_resp.code != '200'

      body = json_to_hash(http_resp.body)
      Chef::Log.debug("Bundle operation response: #{body}")
      body['fragment'] == false && body['stateRaw'] == expected_state
    end

    def osgi_bundle_stability(addr, user, pass, hc_params)
      stability_check(
        addr, '/system/console/bundles/.json', user, pass, hc_params
      )
    end
  end
end
