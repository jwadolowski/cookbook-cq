#
# Cookbook Name:: cq
# Resource:: user
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
    class CqUser < Chef::Resource
      provides :cq_user, :on_platforms => :all

      attr_accessor :path
      attr_accessor :password_hash
      attr_accessor :hash_algo
      attr_accessor :hash_salt
      attr_accessor :hash_iter

      def initialize(name, run_context = nil)
        super

        @resource_name = :cq_user
        @allowed_actions = [:modify, :enable]
        @action = :nothing

        @id = name
        @username = nil
        @password = nil
        @instance = nil
        @email = nil
        @first_name = nil
        @last_name = nil
        @user_password = nil
      end

      def id(arg = nil)
        set_or_return(:id, arg, :kind_of => String)
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

      def email(arg = nil)
        set_or_return(:email, arg, :kind_of => String)
      end

      def first_name(arg = nil)
        set_or_return(:first_name, arg, :kind_of => String)
      end

      def last_name(arg = nil)
        set_or_return(:last_name, arg, :kind_of => String)
      end

      def enable(arg = nil)
        set_or_return(:last_name, arg, :kind_of => [TrueClass, FalseClass])
      end

      def user_password(arg = nil)
        set_or_return(:last_name, arg, :kind_of => String)
      end
    end
  end
end
