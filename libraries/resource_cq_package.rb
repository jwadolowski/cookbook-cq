#
# Cookbook Name:: cq
# Resource:: package
#
# Copyright (C) 2016 Jakub Wadolowski
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
      attr_accessor :remote_path

      attr_accessor :uploaded
      attr_accessor :installed

      attr_accessor :metadata_name
      attr_accessor :metadata_group
      attr_accessor :metadata_version

      attr_accessor :crx_name
      attr_accessor :crx_group
      attr_accessor :crx_version

      def initialize(name, run_context = nil)
        super

        @resource_name = :cq_package
        @allowed_actions = [:nothing, :upload, :install, :deploy, :uninstall]
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
      end

      def name(arg = nil)
        set_or_return(:name, arg, :kind_of => String)
      end

      def username(arg = nil)
        set_or_return(:username, arg, :kind_of => String)
      end

      def password(arg = nil)
        set_or_return(:password, arg, :kind_of => String)
      end

      def instance(arg = nil)
        set_or_return(:instance, arg, :kind_of => String)
      end

      def source(arg = nil)
        set_or_return(:source, arg, :kind_of => String)
      end

      def http_user(arg = nil)
        set_or_return(:http_user, arg, :kind_of => String)
      end

      def http_pass(arg = nil)
        set_or_return(:http_pass, arg, :kind_of => String)
      end

      def recursive_install(arg = nil)
        set_or_return(
          :recursive_install,
          arg,
          :kind_of => [TrueClass, FalseClass]
        )
      end

      def rescue_mode(arg = nil)
        set_or_return(
          :rescue_mode,
          arg,
          :kind_of => [TrueClass, FalseClass]
        )
      end

      def checksum(arg = nil)
        set_or_return(:checksum, arg, :kind_of => String)
      end
    end
  end
end
