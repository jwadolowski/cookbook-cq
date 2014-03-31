#
# Cookbook Name:: cq
# Resource:: user
#
# Copyright (C) 2014 Jakub Wadolowski
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

actions :create, :remove, :modify, :manage
default_action :create

attribute :login, :kind_of => String,
                  :regex => /^([a-zA\-Z-_]+)/,
                  :name_attribute => true,
                  :required => true
attribute :instance_mode, :equal_to => [:author, :publish],
                          :required => true
attribute :password, :kind_of => String,
                     :default => nil
attribute :first_name, :kind_of => String,
                       :default => nil
attribute :last_name, :kind_of => String,
                      :default => nil
attribute :email, :kind_of => String,
                  :default => nil

attr_accessor :exists
