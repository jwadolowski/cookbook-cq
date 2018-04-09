#
# Cookbook Name:: cq
# Resource:: user
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
    class CqUser < Chef::Resource
      provides :cq_user

      attr_accessor :query_result
      attr_accessor :exist
      attr_accessor :path
      attr_accessor :info
      attr_accessor :profile
      attr_accessor :admin_password
      attr_accessor :my_password

      def initialize(name, run_context = nil)
        super

        @resource_name = :cq_user
        @allowed_actions = [:nothing, :modify]
        @action = :nothing

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

      def id(arg = nil)
        set_or_return(:id, arg, kind_of: String)
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

      def email(arg = nil)
        set_or_return(:email, arg, kind_of: String)
      end

      def first_name(arg = nil)
        set_or_return(:first_name, arg, kind_of: String)
      end

      def last_name(arg = nil)
        set_or_return(:last_name, arg, kind_of: String)
      end

      def phone_number(arg = nil)
        set_or_return(:phone_number, arg, kind_of: String)
      end

      def job_title(arg = nil)
        set_or_return(:job_title, arg, kind_of: String)
      end

      def street(arg = nil)
        set_or_return(:street, arg, kind_of: String)
      end

      def mobile(arg = nil)
        set_or_return(:mobile, arg, kind_of: String)
      end

      def city(arg = nil)
        set_or_return(:city, arg, kind_of: String)
      end

      def postal_code(arg = nil)
        set_or_return(:postal_code, arg, kind_of: String)
      end

      def country(arg = nil)
        set_or_return(:country, arg, kind_of: String)
      end

      def state(arg = nil)
        set_or_return(:state, arg, kind_of: String)
      end

      def gender(arg = nil)
        set_or_return(:gender, arg, kind_of: String)
      end

      def about(arg = nil)
        set_or_return(:about, arg, kind_of: String)
      end

      def user_password(arg = nil)
        set_or_return(:user_password, arg, kind_of: String)
      end

      def enabled(arg = nil)
        set_or_return(:enabled, arg, kind_of: [TrueClass, FalseClass])
      end

      def old_password(arg = nil)
        set_or_return(:old_password, arg, kind_of: String)
      end
    end
  end
end
