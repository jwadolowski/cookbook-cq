#
# Cookbook Name:: cq
# Provider:: osgi_component
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

class Chef
  class Provider
    class CqOsgiComponent < Chef::Provider
      include Cq::OsgiComponentHelper

      provides :cq_osgi_component if Chef::Provider.respond_to?(:provides)

      def whyrun_supported?
        true
      end

      def load_current_resource
        @current_resource = Chef::Resource::CqOsgiComponent.new(
          new_resource.pid
        )

        @new_resource.healthcheck_params = healthcheck_params(
          new_resource.rescue_mode,
          new_resource.same_state_barrier,
          new_resource.error_state_barrier,
          new_resource.max_attempts,
          new_resource.sleep_time
        )

        # {
        #   "id": 476,
        #   "name": "com.day.cq.search.suggest.impl.SuggesterImpl",
        #   "state": "active",
        #   "stateRaw": 8,
        #   "pid": "com.day.cq.search.suggest.impl.SuggesterImpl"
        # }
        @current_resource.info = component_info(
          component_list(
            new_resource.instance,
            new_resource.username,
            new_resource.password
          ),
          new_resource.pid
        )

        Chef::Log.debug("Component info: #{current_resource.info}")

        # Stop processing if there's no such component
        Chef::Application.fatal!(
          "#{current_resource.pid} component doesn't exist!"
        ) unless current_resource.info
      end

      def disable_component
        resp = component_op(
          new_resource.instance,
          new_resource.username,
          new_resource.password,
          current_resource.info['id'],
          'disable'
        )

        Chef::Application.fatal!(
          "Expected disabled state, but got #{resp.code} HTTP response and "\
          "#{resp.body} body"
        ) unless valid_component_op?(resp, 'disabled', new_resource.pid)

        osgi_component_stability(
          new_resource.instance,
          new_resource.username,
          new_resource.password,
          new_resource.healthcheck_params
        )
      end

      def enable_component
        resp = component_op(
          new_resource.instance,
          new_resource.username,
          new_resource.password,
          current_resource.info['pid'],
          'enable'
        )

        Chef::Application.fatal!(
          "Expected active state, but got #{resp.code} HTTP response and "\
          "#{resp.body} body"
        ) unless valid_component_op?(resp, 'active', new_resource.pid)

        osgi_component_stability(
          new_resource.instance,
          new_resource.username,
          new_resource.password,
          new_resource.healthcheck_params
        )
      end

      def action_disable
        # Only components in active, satisfied and unsatisfied can be disabled
        if current_resource.info['state'] != 'disabled'
          converge_by("Disable #{new_resource.pid} component") do
            disable_component
          end
        elsif current_resource.info['state'] == 'disabled'
          Chef::Log.info(
            "#{current_resource.pid} component is already disabled"
          )
        else
          Chef::Log.warn(
            "#{current_resource.pid} is in #{current_resource.info['state']} "\
            'state. Only active, satisfied and unsatisfied components can be '\
            'disabled'
          )
        end
      end

      def action_enable
        if current_resource.info['state'] == 'disabled'
          converge_by("Enable #{new_resource.pid} component") do
            enable_component
          end
        elsif current_resource.info['state'] == 'active'
          Chef::Log.info(
            "#{current_resource.pid} component is already enabled"
          )
        else
          Chef::Log.warn(
            "#{current_resource.pid} is in #{current_resource.info['state']} "\
            'state. Only disabled components can be enabled'
          )
        end
      end
    end
  end
end
