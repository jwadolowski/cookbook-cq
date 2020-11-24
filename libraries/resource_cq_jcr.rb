#
# Cookbook:: cq
# Resource:: jcr
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
    class CqJcr < Chef::Resource
      provides :cq_jcr

      attr_accessor :exist

      allowed_actions [:nothing, :create, :delete, :modify]

      resource_name :cq_jcr

      default_action :create

      def initialize(name, run_context = nil)
        super

        @path = name
        @username = nil
        @password = nil
        @instance = nil
        @properties = {}
        @append = true
        @encrypted_fields = []
      end

      property :path, String
      property :username, String
      property :password, String
      property :instance, String
      property :properties, Hash
      property :append, [true, false]
      property :encrypted_fields, Array
    end
  end
end
