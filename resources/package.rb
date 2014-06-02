#
# Cookbook Name:: cq
# Resource:: package
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

actions :create, :build, :download, :install, :delete, :upload
default_action :nothing

attribute :name, :kind_of => String, :name_attribute => true, :required => true
attribute :group, :kind_of => String, :required => false
attribute :version, :kind_of => String, :required => false
attribute :description, :kind_of => String, :required => false
attribute :filters, :kind_of => Hash, :required => false
attribute :source, :kind_of => String, :required => false

attr_accessor :exists?, :installed?
