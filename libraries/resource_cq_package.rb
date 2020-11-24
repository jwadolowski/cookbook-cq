#
# Cookbook:: cq
# Resource:: package
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

      allowed_actions [
          :nothing,
          :upload,
          :install,
          :deploy,
          :uninstall,
          :delete,
        ]

      resource_name :cq_package

      default_action :nothing

      def initialize(name, run_context = nil)
        super

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

      property :username, String
      property :password, String
      property :instance, String
      property :source, String
      property :http_user, String
      property :http_pass, String
      property :recursive_install, [true, false]
      property :rescue_mode, [true, false]
      property :checksum, String
      property :same_state_barrier, Integer
      property :error_state_barrier, Integer
      property :max_attempts, Integer
      property :sleep_time, Integer
    end
  end
end
