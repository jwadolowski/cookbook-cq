#
# Cookbook Name:: cq
# Libraries:: OsgiComponentHelper
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

module Cq
  module OsgiComponentHelper
    include Cq::HealthcheckHelper
    include Cq::HttpHelper

    def component_list(addr, user, password)
      json_to_hash(
        http_get(addr, '/system/console/components/.json', user, password).body
      )
    end

    # pid is unique, hence filtering using .detect
    def component_info(list, pid)
      list['data'].detect { |c| c['pid'] == pid }
    end

    # Executes defined operation on given component
    #
    # Allowed actions:
    # * enable (requires pid)
    # * disable (requires id)
    def component_op(addr, user, password, id, op)
      req_path = "/system/console/components/#{id}"
      payload = { 'action' => op }

      http_post(addr, req_path, user, password, payload)
    end

    # Component operation returns complete list of OSGi components. It needs to
    # be filtered
    def valid_component_op?(http_resp, expected_state, pid)
      return false if http_resp.code != '200'

      body = component_info(json_to_hash(http_resp.body), pid)
      Chef::Log.debug("Post-action component information: #{body}")
      body['state'] == expected_state
    end

    def osgi_component_stability(addr, user, pass, hc_params)
      stability_check(
        addr, '/system/console/components/.json', user, pass, hc_params
      )
    end
  end
end
