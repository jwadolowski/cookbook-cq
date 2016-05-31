#
# Cookbook Name:: cq
# Resource:: osgi_bundle
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
  class Resource
    class CqOsgiBundle < Chef::Resource
      provides :cq_osgi_bundle

      attr_accessor :info

      def initialize(name, run_context = nil)
        super

        @resource_name = :cq_osgi_bundle
        @allowed_actions = [:nothing, :stop, :start, :update, :refresh]
        @action = :nothing

        @symbolic_name = name
        @username = nil
        @password = nil
        @instance = nil
      end

      def symbolic_name(arg = nil)
        set_or_return(:symbolic_name, arg, :kind_of => String)
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
    end
  end
end
