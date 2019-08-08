#
# Cookbook:: cq
# Libraries:: OsgiComponentHelper
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

    def component_get(addr, user, password, pid)
      list = json_to_hash(
        http_get(addr, "/system/console/components/#{pid}.json", user, password).body
      )
      component_info(list, pid)
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
    def valid_component_op?(addr, user, password, http_resp, expected_state, pid, hc_params)
      # Check if POST request was successful
      if http_resp.code != '200'
        Chef::Log.error(
          "POST request returned #{http_resp.code} code (expected 200)" \
          "and #{http_resp.body} body"
        )
        return false
      end

      max_checks = 4

      # Call API again to check component state
      (1..max_checks).each do |i|
        Chef::Log.debug(
          "Retrying component check in #{hc_params['sleep_time']} sec, #{i}/#{max_checks} attempts."
        ) if i > 1

        sleep hc_params['sleep_time']

        info = component_get(addr, user, password, pid)

        if info['state'] == expected_state
          Chef::Log.debug("Post-action component information: #{info}")
          return true
        end

        Chef::Log.error(
          "Expected #{expected_state} state, but got #{info['state']} after #{i} checks"
        ) if i == max_checks
      end
      false
    end

    def osgi_component_stability(addr, user, pass, hc_params)
      stability_check(
        addr, '/system/console/components/.json', user, pass, hc_params
      )
    end
  end
end
