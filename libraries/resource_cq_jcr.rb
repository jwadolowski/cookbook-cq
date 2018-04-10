#
# Cookbook Name:: cq
# Resource:: jcr
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
    class CqJcr < Chef::Resource
      provides :cq_jcr

      attr_accessor :exist

      def initialize(name, run_context = nil)
        super

        @resource_name = :cq_jcr
        @allowed_actions = [:nothing, :create, :delete, :modify]
        @action = :create

        @path = name
        @username = nil
        @password = nil
        @instance = nil
        @properties = {}
        @append = true
        @encrypted_fields = []
      end

      def path(arg = nil)
        set_or_return(:path, arg, kind_of: String)
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

      def properties(arg = nil)
        set_or_return(:properties, arg, kind_of: Hash)
      end

      def append(arg = nil)
        set_or_return(:append, arg, kind_of: [TrueClass, FalseClass])
      end

      def encrypted_fields(arg = nil)
        set_or_return(:encrypted_fields, arg, kind_of: Array)
      end
    end
  end
end
