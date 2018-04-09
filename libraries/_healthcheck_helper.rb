#
# Cookbook Name:: cq
# Libraries:: HealthcheckHelper
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
  module HealthcheckHelper
    include Cq::HttpHelper

    def healthcheck_params(rescue_mode, same_state_barrier,
                           error_state_barrier, max_attempts, sleep_time)
      {
        'rescue_mode' => rescue_mode,
        'same_state_barrier' => same_state_barrier,
        'error_state_barrier' => error_state_barrier,
        'max_attempts' => max_attempts,
        'sleep_time' => sleep_time,
      }
    end

    def path_desc(path)
      case path
      when '/system/console/bundles/.json'
        'bundles'
      when '/system/console/components/.json'
        'components'
      end
    end

    def stability_check(addr, path, user, password, hc_params)
      Chef::Log.info("Waiting for stable state of OSGi #{path_desc(path)}...")

      # Save current net read timeout value
      current_timeout = node['cq']['http_read_timeout']

      # Previous state (start with empty)
      previous_state = ''

      # How many times the state hasn't changed in a row
      same_state_counter = 0

      # How many times an error occurred in a row
      error_state_counter = 0

      (1..hc_params['max_attempts']).each do |i|
        begin
          # Reduce net read time value to speed up OSGi healthcheck procedure
          # when instance is running but stopped accepting HTTP requests
          node.default['cq']['http_read_timeout'] = 5
          state = http_get(addr, path, user, password)

          # Handle response errors
          raise(Net::HTTPUnknownResponse) unless state.is_a?(Net::HTTPResponse)
          raise(Net::HTTPBadResponse) unless state.code == '200'

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
          if same_state_counter == hc_params['same_state_barrier']
            Chef::Log.info(
              "OSGi #{path_desc(path)} seem to be stable. Moving on..."
            )
            break
          end
        rescue => e
          Chef::Log.warn(
            "Unable to get OSGi #{path_desc(path)} state: #{e}. Retrying..."
          )

          # Let's start over in case of an error (clear indicator of flapping
          # OSGi bundles/component)
          previous_state = ''
          same_state_counter = 0

          # Increment error_state_counter in case of an error
          error_state_counter += 1
          Chef::Log.info("Error state counter: #{error_state_counter}")

          # If error occurred N times in a row and rescue_mode is active then
          # log such event and break the loop
          if hc_params['rescue_mode'] &&
             error_state_counter == hc_params['error_state_barrier']
            Chef::Log.error(
              "#{hc_params['error_state_barrier']} recent attempts to get "\
              "OSGi #{path_desc(path)} state have failed! Rescuing, as "\
              'rescue_mode is active...'
            )
            break
          end
        ensure
          # Restore original timeout
          node.default['cq']['http_read_timeout'] = current_timeout
        end

        Chef::Application.fatal!(
          "Cannot detect stable state after #{hc_params['max_attempts']} "\
          'attempts!'
        ) if i == hc_params['max_attempts']

        Chef::Log.info(
          "[#{i}/#{hc_params['max_attempts']}] Next check of OSGi "\
          "#{path_desc(path)} in #{hc_params['sleep_time']}s..."
        )

        sleep hc_params['sleep_time']
      end
    end
  end
end
