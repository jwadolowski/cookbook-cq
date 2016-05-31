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

    def raw_bundle_list(addr, user, password)
      http_get(addr, '/system/console/bundles/.json', user, password)
    end

    def bundle_list(addr, user, password)
      json_to_hash(raw_bundle_list(addr, user, password).body)
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
      body['fragment'] == false && body['stateRaw'] == expected_state
    end

    def osgi_stability_healthcheck(addr, user, password, rescue_mode,
                                   same_state_barrier, error_state_barrier,
                                   max_attempts, sleep_time)
      Chef::Log.info('Waiting for stable state of OSGi bundles...')

      # Previous state of OSGi bundles (start with empty)
      previous_state = ''

      # How many times the state hasn't changed in a row
      same_state_counter = 0

      # How many times an error occurred in a row
      error_state_counter = 0

      (1..max_attempts).each do |i|
        begin
          state = raw_bundle_list(addr, user, password)

          # Raise an error if state is not an instance of HTTP response
          raise('Invalid HTTP response') unless state.is_a?(Net::HTTPResponse)

          # Reset error counter whenever request ended successfully
          error_state_counter = 0

          if state.body == previous_state
            same_state_counter += 1
          else
            same_state_counter = 0
          end

          Chef::Log.info("Same state counter: #{same_state_counter}")

          # Assign current state to previous state
          previous_state = state.body

          # Move on if the same state occurred N times in a row
          if same_state_counter == same_state_barrier
            Chef::Log.info('OSGi bundles seem to be stable. Moving on...')
            break
          end
        rescue => e
          Chef::Log.warn("Unable to get OSGi bundles state: #{e}. Retrying...")

          # Let's start over in case of an error (clear indicator of flapping
          # OSGi bundles)
          previous_state = ''
          same_state_counter = 0

          # Increment error_state_counter in case of an error
          error_state_counter += 1
          Chef::Log.info("Error state counter: #{error_state_counter}")

          # If error occurred N times in a row and rescue_mode is active then
          # log such event and break the loop
          if rescue_mode && error_state_counter == error_state_barrier
            Chef::Log.error(
              "#{error_state_barrier} recent attempts to get OSGi bundles "\
              'state have failed! Rescuing, as rescue_mode is active...'
            )
            break
          end
        end

        Chef::Application.fatal!(
          "Cannot detect stable state after #{max_attempts} attempts!"
        ) if i == max_attempts

        Chef::Log.info(
          "[#{i}/#{max_attempts}] Next OSGi status check in #{sleep_time}s..."
        )

        sleep sleep_time
      end
    end
  end
end
