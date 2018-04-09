#
# Cookbook Name:: cq
# Resource:: package
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
    class CqPackage < Chef::Resource
      provides :cq_package

      attr_accessor :local_path

      attr_accessor :uploaded
      attr_accessor :installed

      # Package metadata from properties.xml
      attr_accessor :xml_name
      attr_accessor :xml_group
      attr_accessor :xml_version

      # Package metadata from CRX Package Manager
      attr_accessor :crx_name
      attr_accessor :crx_group
      attr_accessor :crx_version
      attr_accessor :crx_download_name

      attr_accessor :healthcheck_params

      def initialize(name, run_context = nil)
        super

        @resource_name = :cq_package
        @allowed_actions = [
          :nothing,
          :upload,
          :install,
          :deploy,
          :uninstall,
          :delete,
        ]
        @action = :nothing

        @name = name
        @username = nil
        @password = nil
        @instance = nil
        @source = nil
        @http_user = nil
        @http_pass = nil
        @recursive_install = false
        @rescue_mode = false
        @checksum = nil
        @same_state_barrier = 6
        @error_state_barrier = 6
        @max_attempts = 30
        @sleep_time = 10
      end

      def name(arg = nil)
        set_or_return(:name, arg, kind_of: String)
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

      def source(arg = nil)
        set_or_return(:source, arg, kind_of: String)
      end

      def http_user(arg = nil)
        set_or_return(:http_user, arg, kind_of: String)
      end

      def http_pass(arg = nil)
        set_or_return(:http_pass, arg, kind_of: String)
      end

      def recursive_install(arg = nil)
        set_or_return(
          :recursive_install,
          arg,
          kind_of: [TrueClass, FalseClass]
        )
      end

      def rescue_mode(arg = nil)
        set_or_return(:rescue_mode, arg, kind_of: [TrueClass, FalseClass])
      end

      def checksum(arg = nil)
        set_or_return(:checksum, arg, kind_of: String)
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
