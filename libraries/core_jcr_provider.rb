#
# Cookbook Name:: cq
# Provider:: jcr
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
    class CqJcr < Chef::Provider
      include Cq::Helper

      # Chef 12.4.0 support
      provides :cq_jcr if Chef::Provider.respond_to?(:provides)

      def whyrun_supported?
        true
      end

      def load_current_resource
      end

      def action_create
        fail Chef::Exceptions::UnsupportedAction,
             "#{self} does not support :create"
      end

      def action_delete
        fail Chef::Exceptions::UnsupportedAction,
             "#{self} does not support :delete"
      end

      def action_modify
        fail Chef::Exceptions::UnsupportedAction,
             "#{self} does not support :modify"
      end
    end
  end
end
