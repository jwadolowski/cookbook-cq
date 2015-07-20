#
# Cookbook Name:: cq
# Provider:: user
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
  class Provider
    class CqAdminUser < Chef::Provider::CqUser
      def load_current_resource
        @current_resource = Chef::Resource::CqUser.new('admin')

        @current_resource.admin_password = current_password

        @current_resource.path = user_path(
          new_resource.username,
          current_resource.admin_password
        )
        @current_resource.info = user_info(
          new_resource.username,
          current_resource.admin_password
        )
        @current_resource.profile = user_profile(
          new_resource.username,
          current_resource.admin_password
        )

        Chef::Log.error("Current [path]: #{current_resource.path}")
        Chef::Log.error("Current [info]: #{current_resource.info}")
        Chef::Log.error("Current [profile]: #{current_resource.profile}")
        Chef::Log.error("Current [enabled]: #{current_resource.enabled}")
        Chef::Log.error(
          "Current [user_password]: #{current_resource.user_password}"
        )
      end

      def current_password
        req_path = '/libs/granite/core/content/login.html'

        [new_resource.password, new_resource.old_password, 'admin'].each do |p|
          http_resp = http_get(new_resource.instance, req_path, 'admin', p)

          return p if http_resp.code == '200'
         end

        Chef::Application.fatal!(
          "Unable to determine valid admin credentials! The following "\
          "user/pass pairs were checked: \n"\
          "* admin / <password>\n"\
          "* admin / <old_password>\n"\
          '* admin / admin'
        )
      end

      def action_modify
        if password_update?(new_resource.password) || !profile_diff.empty?
          converge_by("Update user #{new_resource.id}") do
            profile_update(
              new_resource.username,
              current_resource.current_password,
              new_resource.password
            )
          end
        else
          Chef::Log.info(
            "User #{new_resource.id} is already configured as defined"
          )
        end
      end
    end
  end
end
