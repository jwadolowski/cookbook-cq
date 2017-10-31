#
# Cookbook Name:: cq
# Libraries:: InstanceHelper
#
# Copyright (C) 2017 Jakub Wadolowski
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

require_relative '_http_helper'

module Cq
  module InstanceHelper
    include Cq::HttpHelper

    def start_guard_timeout_params(timeout, sleep_time, http_timeout)
      {
        'timeout' => timeout,
        'sleep_time' => sleep_time,
        'http_timeout' => http_timeout
      }
    end

    def start_guard_input_params(path, http_code, str)
      {
        'path' => path,
        'http_code' => http_code,
        'test_string' => str
      }
    end

    def expected_response?(response, params)
      if params['test_string']
        response.code == params['http_code'] &&
          response.body.include?(params['test_string'])
      else
        response.code == params['http_code']
      end
    end

    def elapsed_time(start_time)
      Time.now - start_time
    end

    def start_guard(addr, input_params, timeout_params)
      start_time ||= Time.now

      # HTTP NetReadTimeout changes:
      # * save its current value, so it can be restored at the very end
      # * reduce it to speed the whole process up
      current_http_timeout ||= node['cq']['http_read_timeout']
      node.default['cq']['http_read_timeout'] = timeout_params['http_timeout']

      resp = http_get(addr, input_params['path'], nil, nil)

      unless resp.is_a?(Net::HTTPResponse)
        raise(Net::HTTPUnknownResponse, 'Unknown HTTP response')
      end

      unless expected_response?(resp, input_params)
        raise(Net::HTTPBadResponse, 'Wrong HTTP response')
      end

      Chef::Log.info("CQ start time: #{elapsed_time(start_time)} seconds")
    rescue
      if elapsed_time(start_time) < timeout_params['timeout']
        sleep(timeout_params['sleep_time'])
        retry
      else
        Chef::Application.fatal!(
          'Chef run aborted, as CQ start took more than '\
          "#{timeout_params['timeout']} seconds!"
        )
      end
    ensure
      # Restore original HTTP timeout
      node.default['cq']['http_read_timeout'] = current_http_timeout
    end
  end
end
