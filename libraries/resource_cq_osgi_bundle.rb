#
# Cookbook Name:: cq
# Resource:: osgi_bundle
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
    class CqOsgiBundle < Chef::Resource
      provides :cq_osgi_bundle

      attr_accessor :info
      attr_accessor :healthcheck_params

      def initialize(name, run_context = nil)
        super

        @resource_name = :cq_osgi_bundle
        @allowed_actions = [:nothing, :stop, :start]
        @action = :nothing

        @symbolic_name = name
        @username = nil
        @password = nil
        @instance = nil
        @rescue_mode = false
        @same_state_barrier = 3
        @error_state_barrier = 3
        @max_attempts = 30
        @sleep_time = 3
      end

      def symbolic_name(arg = nil)
        set_or_return(:symbolic_name, arg, kind_of: String)
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
