#
# Cookbook Name:: cq
# Resource:: cq_clientlib_cache
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

include Cq::HttpHelper

resource_name :cq_clientlib_cache

property :name, String, name_property: true
property :instance, String, default: 'http://localhost:4502'
property :username, String, default: 'admin'
property :password, String, default: 'admin'

default_action :nothing

action_class do
  def http_endpoint
    '/libs/granite/ui/content/dumplibs.rebuild.html'
  end

  def sleep_time(attempt)
    1 + (2**attempt) + rand(2**attempt)
  end

  def cache_action(action)
    max_attempts ||= 3
    attempt ||= 1
    qs ||= case action
           when :invalidate
             { invalidate: 'true' }
           when :rebuild
             { rebuild: 'true' }
           end

    http_resp = http_get(
      new_resource.instance,
      http_endpoint,
      new_resource.username,
      new_resource.password,
      qs
    )

    unless http_resp.is_a?(Net::HTTPResponse)
      raise(Net::HTTPUnknownResponse, 'Unknown HTTP response')
    end

    unless http_resp.code == '200'
      raise(Net::HTTPBadResponse, "#{resp.code} error")
    end

    Chef::Log.debug("Clientlib endpoint response code: #{http_resp.code}")
    Chef::Log.debug("Clientlib response response body: #{http_resp.body}")
  rescue => e
    if (attempt += 1) <= max_attempts
      t = sleep_time(attempt)
      Chef::Log.error(
        "[#{attempt}/#{max_attempts}] Retrying in #{t}s (reason: #{e})"
      )
      sleep(t)
      retry
    else
      Chef::Application.fatal!(
        "Unable to #{action} clientlibs after #{max_attempts} attempts"
      )
    end
  end
end

action :invalidate do
  cache_action(:invalidate)
end

action :rebuild do
  cache_action(:rebuild)
end
