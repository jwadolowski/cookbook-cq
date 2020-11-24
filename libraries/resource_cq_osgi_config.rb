#
# Cookbook:: cq
# Resource:: osgi_config
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
    class CqOsgiConfig < Chef::Resource
      provides :cq_osgi_config

      attr_accessor :info
      attr_accessor :default_properties
      attr_accessor :fingerprint
      attr_accessor :fingerprint_groups
      attr_accessor :healthcheck_params

      allowed_actions [:nothing, :create, :delete]

      resource_name :cq_osgi_config

      default_action :nothing

      def initialize(pid, run_context = nil)
        super

        @pid = pid
        @username = nil
        @password = nil
        @instance = nil
        @factory_pid = nil
        @properties = {}
        @append = false
        @apply_all = false
        @include_missing = true
        @unique_fields = []
        @count = 1
        @enforce_count = false
        @force = false
        @rescue_mode = false
        @same_state_barrier = 3
        @error_state_barrier = 3
        @max_attempts = 60
        @sleep_time = 2
      end

      property :pid, String
      property :username, String
      property :password, String
      property :instance, String
      property :factory_pid, String
      property :properties, Hash
      property :append, [true, false]
      property :apply_all, [true, false]
      property :include_missing, [true, false]
      property :unique_fields, Array
      property :count, Integer
      property :enforce_count, [true, false]
      property :force, [true, false]
      property :rescue_mode, [true, false]
      property :same_state_barrier, Integer
      property :error_state_barrier, Integer
      property :max_attempts, Integer
      property :sleep_time, Integer
    end
  end
end
