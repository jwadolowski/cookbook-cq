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

        if current_resource.exist
          @node_info = node_info(@raw_node_info)

          @current_resource.type(@node_info['jcr:primaryType'])
          @current_resource.properties(filtered_properties(@node_info))
        end

        Chef::Log.error("Current [exist]: #{current_resource.exist}")
        Chef::Log.error("Current [type]: #{current_resource.type}")
        Chef::Log.error("Current [properties]: #{current_resource.properties}")
      end

      def action_create
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

      def filtered_properties(hash)
        hash.delete_if { |k, _v| k == 'jcr:primaryType' }
      end
    end
  end
end
