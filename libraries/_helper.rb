#
# Cookbook Name:: cq
# Libraries:: helper
#
# Copyright (C) 2015 Jakub Wadolowski
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

require 'net/http'
require 'uri'
require 'json'

module Cq
  module Helper
    def uri_parser(addr, path)
      URI.parse(addr + path)
    rescue => e
      Chef::Application.fatal!("Invalid URI: #{e}")
    end

    def http_get(addr, path, user, password)
      uri = uri_parser(addr, path)

      http = Net::HTTP.new(uri.host, uri.port)
      http_req = Net::HTTP::Get.new(uri.request_uri)
      http_req.basic_auth(user, password)

      begin
        http.request(http_req)
      rescue => e
        Chef::Log.error("Unable to send GET request: #{e}")
      end
    end

    def json_to_hash(str)
      JSON.parse(str)
    rescue => e
      Chef::Application.fatal!("Unable to parse #{str} as JSON: #{e}")
    end

    def http_post(addr, path, user, password, payload)
      uri = uri_parser(addr, path)

      http = Net::HTTP.new(uri.host, uri.port)
      http_req = Net::HTTP::Post.new(uri.request_uri)
      http_req.basic_auth(user, password)
      http_req.set_form_data(payload)

      begin
        http.request(http_req)
      rescue => e
        Chef::Log.error("Unable to send POST request: #{e}")
      end
    end
  end
end
