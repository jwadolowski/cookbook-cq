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

actions :modify

default_action :nothing

attribute :id,                :kind_of => String, :name_attribute => true,
                              :required => true
attribute :username,          :kind_of => String, :required => true
attribute :password,          :kind_of => String, :required => true
attribute :instance,          :kind_of => String, :required => true
attribute :email,             :kind_of => String, :required => false
attribute :first_name,        :kind_of => String, :required => false
attribute :last_name,         :kind_of => String, :required => false
attribute :phone_number,      :kind_of => String, :required => false
attribute :job_tile,          :kind_of => String, :required => false
attribute :street,            :kind_of => String, :required => false
attribute :mobile,            :kind_of => String, :required => false
attribute :city,              :kind_of => String, :required => false
attribute :postal_code,       :kind_of => String, :required => false
attribute :country,           :kind_of => String, :required => false
attribute :state,             :kind_of => String, :required => false
attribute :title,             :kind_of => String, :required => false
attribute :gender,            :kind_of => String, :required => false
attribute :about,             :kind_of => String, :required => false
attribute :enable,            :kind_of => [TrueClass, FalseClass],
                              :required => false, :default => true
attribute :user_password,     :kind_of => String, :required => false
attribute :old_user_password, :kind_of => String, :required => false
