#
# Cookbook Name:: cq
# Provider:: user
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

def whyrun_supported?
  true
end

def uri_parser(request_uri)
  require 'uri'

  begin
    URI.parse(new_resource.instance + request_uri)
  rescue => e
    Chef::Application.fatal!("#{new_resource.instance} is not a valid URI!\n"\
                             "Error description: #{e}")
  end
end

def instance_get_request(request_uri)
  require 'net/http'
  require 'uri'

  uri = uri_parser(request_uri)

  http_request = Net::HTTP::Get.new(
    uri.request_uri
  ).basic_auth(new_resource.username, new_resource.password)

  begin
    Net::HTTP.new(uri.host, uri.port).request(http_request)
  rescue => e
    Chef::Application.fatal!("HTTP request failure: #{e}")
  end
end

def user_path
  require 'json'

  request_uri = '/bin/querybuilder.json?'\
    'path=/home/users&'\
    '1_property=rep:authorizableId&'\
    "1_property.value=#{new_resource.id}&"\
    'p.limit=-1'

  response = instance_get_request(request_uri)

  json_response = JSON.parse(response.body)

  Chef::Application.fatal!(
    'Total number of returned records is not equal 1!'
  ) if json_response['total'] != 1

  json_response['hits'][0]['path']
end

def load_current_resource
  @current_resource = Chef::Resource::CqUser.new(new_resource.name)

  @current_resource.id(new_resource.id)

  # Get user path
  @user_path = user_path
end

action :modify do
  # TODO
end
