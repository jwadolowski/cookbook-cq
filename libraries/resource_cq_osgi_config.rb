#
# Cookbook Name:: cq
# Resource:: osgi_config
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
  class Resource
    class CqOsgiConfig < Chef::Resource
      provides :cq_osgi_config

      attr_accessor :info
      attr_accessor :default_properties
      attr_accessor :fingerprint
      attr_accessor :fingerprint_groups
      attr_accessor :healthcheck_params

      def initialize(pid, run_context = nil)
        super

        @resource_name = :cq_osgi_config
        @allowed_actions = [:nothing, :create, :delete]
        @action = :nothing

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

      def pid(arg = nil)
        set_or_return(:pid, arg, kind_of: String)
      end

      def username(arg = nil)
        set_or_return(:username, arg, kind_of: String)
      end

      def password(arg = nil)
        set_or_return(:password, arg, kind_of: String)
      end

      def instance(arg = nil)
        set_or_return(:instance, arg, kind_of: String)
      end

      def factory_pid(arg = nil)
        set_or_return(:factory_pid, arg, kind_of: String)
      end

      def properties(arg = nil)
        set_or_return(:properties, arg, kind_of: Hash)
      end

      def append(arg = nil)
        set_or_return(:append, arg, kind_of: [TrueClass, FalseClass])
      end

      def apply_all(arg = nil)
        set_or_return(:apply_all, arg, kind_of: [TrueClass, FalseClass])
      end

      def include_missing(arg = nil)
        set_or_return(
          :include_missing, arg, kind_of: [TrueClass, FalseClass]
        )
      end

      def unique_fields(arg = nil)
        set_or_return(:unique_fields, arg, kind_of: Array)
      end

      def count(arg = nil)
        set_or_return(:count, arg, kind_of: Integer)
      end

      def enforce_count(arg = nil)
        set_or_return(:enforce_count, arg, kind_of: [TrueClass, FalseClass])
      end

      def force(arg = nil)
        set_or_return(:force, arg, kind_of: [TrueClass, FalseClass])
      end

      def rescue_mode(arg = nil)
        set_or_return(:rescue_mode, arg, kind_of: [TrueClass, FalseClass])
      end

      def same_state_barrier(arg = nil)
        set_or_return(:same_state_barrier, arg, kind_of: Integer)
      end

      def error_state_barrier(arg = nil)
        set_or_return(:error_state_barrier, arg, kind_of: Integer)
      end

      def max_attempts(arg = nil)
        set_or_return(:max_attempts, arg, kind_of: Integer)
      end

      def sleep_time(arg = nil)
        set_or_return(:sleep_time, arg, kind_of: Integer)
      end
    end
  end
end
