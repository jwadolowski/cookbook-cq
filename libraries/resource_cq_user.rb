#
# Cookbook:: cq
# Resource:: user
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
    class CqUser < Chef::Resource
      provides :cq_user

      attr_accessor :query_result
      attr_accessor :exist
      attr_accessor :path
      attr_accessor :info
      attr_accessor :profile
      attr_accessor :admin_password
      attr_accessor :my_password

      allowed_actions [:nothing, :modify]

      resource_name :cq_user

      default_action :nothing

      def initialize(name, run_context = nil)
        super

        @id = name
        @username = nil
        @password = nil
        @instance = nil
        @email = nil
        @first_name = nil
        @last_name = nil
        @phone_number = nil
        @job_title = nil
        @street = nil
        @mobile = nil
        @city = nil
        @postal_code = nil
        @country = nil
        @state = nil
        @gender = nil
        @about = nil
        @user_password = nil
        @enabled = true
        @old_password = nil
      end

      property :id, String
      property :username, String
      property :password, String
      property :instance, String
      property :email, String
      property :first_name, String
      property :last_name, String
      property :phone_number, String
      property :job_title, String
      property :street, String
      property :mobile, String
      property :city, String
      property :postal_code, String
      property :country, String
      property :state, String
      property :gender, String
      property :about, String
      property :user_password, String
      property :enabled, [true, false]
      property :old_password, String
    end
  end
end
