#
# Cookbook:: cq
# Resource:: osgi_component
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

class Chef
  class Resource
    class CqOsgiComponent < Chef::Resource
      provides :cq_osgi_component

      attr_accessor :info
      attr_accessor :healthcheck_params

      allowed_actions [:nothing, :enable, :disable]

      resource_name :cq_osgi_component

      default_action :nothing

      def initialize(name, run_context = nil)
        super

        @pid = name
        @username = nil
        @password = nil
        @instance = nil
        @rescue_mode = false
        @same_state_barrier = 3
        @error_state_barrier = 3
        @max_attempts = 30
        @sleep_time = 3
      end

      property :pid, String
      property :username, String
      property :password, String
      property :instance, String
      property :rescue_mode, [true, false]
      property :same_state_barrier, Integer
      property :error_state_barrier, Integer
      property :max_attempts, Integer
      property :sleep_time, Integer
    end
  end
end
