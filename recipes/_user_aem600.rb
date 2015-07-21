#
# Cookbook Name:: cq
# Recipe:: _user_aem600
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

Chef::Log.warn(
  'This is a test recipe and must not be used outside of test kitchen!'
)

cq_user 'admin' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"

  email 'admins@cognifide.com'
  first_name 'Clark'
  last_name 'Kent'
  job_title 'Global Implementation Coordinator'
  street '42 Wall Street'
  city 'New York'
  postal_code '10001'
  country 'United States'
  state 'New York'
  phone_number '+1 999 999 999'
  mobile '+1 111 111 111'
  gender 'male'
  about 'Superman!'
  old_password node['cq']['author']['credentials']['old_password']

  action :modify
end

cq_user 'author' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"

  email 'author@adobe.com'
  first_name 'John'
  last_name 'Doe'
  job_title 'Legacy Intranet Technician'
  street '42 One Way Rd.'
  city 'London'
  postal_code 'P0ST4L C0D3'
  country 'United Kingdom'
  state 'State X'
  phone_number '+00 123 45 67'
  mobile '+00 111 222 333'
  gender 'male'
  about 'The most awesome AEM author on the planet!'
  enabled false
  user_password 's3cret'

  action :modify
end
