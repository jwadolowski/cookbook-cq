#
# Cookbook Name:: cq
# Libraries:: HttpHelper
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

require 'net/http'
require 'uri'

module Cq
  module HttpHelper
    def parse_uri(str, query = nil)
      require 'addressable/uri'

      uri = Addressable::URI.parse(str)
      uri.query_values = query
      uri.normalize
    rescue => e
      Chef::Application.fatal!("Invalid URI: #{e}")
    end

    def json_to_hash(str)
      require 'json'

      JSON.parse(str)
    rescue => e
      Chef::Application.fatal!("Unable to parse #{str} as JSON: #{e}")
    end

    def http_get(addr, path, user, password, query = nil)
      uri = parse_uri(addr + path, query)

      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = node['cq']['http_read_timeout']
      http_req = Net::HTTP::Get.new(uri.request_uri)
      http_req.basic_auth(user, password) if !user.nil? && !password.nil?

      begin
        http.request(http_req)
      rescue => e
        Chef::Log.error("Unable to send GET request: #{e}")
      end
    end

    def http_delete(addr, path, user, password, query = nil)
      uri = parse_uri(addr + path, query)

      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = node['cq']['http_read_timeout']
      http_req = Net::HTTP::Delete.new(uri.request_uri)
      http_req.basic_auth(user, password) if !user.nil? && !password.nil?

      begin
        http.request(http_req)
      rescue => e
        Chef::Log.error("Unable to send DELETE request: #{e}")
      end
    end

    def http_post(addr, path, user, password, payload, query = nil)
      uri = parse_uri(addr + path, query)

      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = node['cq']['http_read_timeout']
      http_req = Net::HTTP::Post.new(uri.request_uri)
      http_req.basic_auth(user, password) if !user.nil? && !password.nil?
      http_req.set_form_data(payload)

      begin
        http.request(http_req)
      rescue => e
        Chef::Log.error("Unable to send POST request: #{e}")
      end
    end

    def http_multipart_post(addr, path, user, password, payload, query = nil)
      require 'net/http/post/multipart'

      uri = parse_uri(addr + path, query)
      http = Net::HTTP.new(uri.host, uri.port)
      http.read_timeout = node['cq']['http_read_timeout']
      http_req = Net::HTTP::Post::Multipart.new(uri.request_uri, payload)
      http_req.basic_auth(user, password) if !user.nil? && !password.nil?

      begin
        http.request(http_req)
      rescue => e
        Chef::Log.error("Unable to send POST request: #{e}")
      end
    end

    def file_upload_payload(key, file_path, content_type)
      require 'net/http/post/multipart'

      { key => UploadIO.new(::File.new(file_path), content_type) }
    end

    def auth_header_required?(user, pass)
      !(user.to_s == '') && !(pass.to_s == '')
    end

    def uri_basename(str)
      ::File.basename(parse_uri(str).path)
    end
  end
end
