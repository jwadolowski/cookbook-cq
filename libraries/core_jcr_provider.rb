#
# Cookbook Name:: cq
# Provider:: jcr
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

class Chef
  class Provider
    class CqJcr < Chef::Provider
      include Cq::Helper

      # Chef 12.4.0 support
      provides :cq_jcr if Chef::Provider.respond_to?(:provides)

      def whyrun_supported?
        true
      end

      def load_current_resource
        @current_resource = Chef::Resource::CqJcr.new(new_resource.path)

        @raw_node_info = raw_node_info
        @current_resource.exist = exist?(@raw_node_info)

        @current_resource.properties(
          node_info(@raw_node_info)
        ) if current_resource.exist

        Chef::Log.error("Current [exist]: #{current_resource.exist}")
        Chef::Log.error("Current [properties]: #{current_resource.properties}")
        Chef::Log.error("Properties diff: #{properties_diff}")
      end

      def action_create
        if !current_resource.exist
          converge_by("Create #{new_resource.path} node") do
            create_new_node
          end
        else
          # TODO
        end
      end

      def action_delete
      end

      def action_modify
      end

      def raw_node_info
        req_path = "#{new_resource.path}.json"

        http_get(
          new_resource.instance,
          req_path,
          new_resource.username,
          new_resource.password
        )
      end

      def exist?(http_resp)
        return true if http_resp.code == '200'
        false
      end

      def node_info(http_resp)
        json_to_hash(http_resp.body)
      end

      def merged_new_resource_properties
        current_resource.properties
          .merge(new_resource.properties)
      end

      def create_new_node
        http_resp = http_multipart_post(
          new_resource.instance,
          new_resource.path,
          new_resource.username,
          new_resource.password,
          new_resource.properties
        )

        Chef::Application.fatal!(
          "Something went wrong during #{new_resource.path} node creation: \n"\
          "HTTP response code: #{http_resp.code}\n"\
          "HTTP response body: #{http_resp.body}\n"\
          'Please check error.log file to get more info.'
        ) unless http_resp.code.start_with?('20')
      end

      def properties_diff
        diff = {}

        if new_resource.append
          properties = merged_new_resource_properties

          properties.each do |k, v|
            diff[k] = v if properties[k] != current_resource.properties[k]
          end
        else
          new_resource.properties.each do |k, v|
            diff[k] = v if new_resource.properties[k] !=
              current_resource.properties[k]
          end
        end

        diff
      end
    end
  end
end
