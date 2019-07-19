#
# Cookbook:: cq
# Resource:: cq_start_guard
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

include Cq::HttpHelper

resource_name :cq_start_guard

property :instance, String, default: 'http://localhost:4502'
property :path, String, default: '/libs/granite/core/content/login.html'
property :expected_code, String, default: '200'
property :expected_body, String, default: '<!-- QUICKSTART_HOMEPAGE - (string used for readyness detection, do not remove) -->'
property :timeout, Integer, default: 1800
property :http_timeout, Integer, default: 5
property :interval, Integer, default: 5

default_action :nothing

action_class do
  def expected_response?(http_response)
    if new_resource.expected_body
      http_response.code == new_resource.expected_code &&
        http_response.body.include?(new_resource.expected_body)
    else
      http_response.code == new_resource.expected_code
    end
  end

  def elapsed_time(start_time)
    Time.now - start_time
  end
end

action :run do
  begin
    start_time ||= Time.now

    # HTTP NetReadTimeout changes:
    # * save its current value, so it can be restored at the very end
    # * reduce it to speed the whole process up
    current_http_timeout ||= node['cq']['http_read_timeout']
    node.default['cq']['http_read_timeout'] = new_resource.http_timeout

    resp = http_get(new_resource.instance, new_resource.path, nil, nil)

    unless resp.is_a?(Net::HTTPResponse)
      raise(Net::HTTPUnknownResponse, 'Unknown HTTP response')
    end

    unless expected_response?(resp)
      raise(Net::HTTPBadResponse, 'Wrong HTTP response')
    end

    Chef::Log.info("CQ start time: #{elapsed_time(start_time)} seconds")
  rescue
    if elapsed_time(start_time) < new_resource.timeout
      sleep(new_resource.interval)
      retry
    else
      Chef::Application.fatal!(
        "Chef run aborted, as CQ start took more than #{new_resource.timeout}s"
      )
    end
  ensure
    # Restore original HTTP timeout
    node.default['cq']['http_read_timeout'] = current_http_timeout
  end
end
