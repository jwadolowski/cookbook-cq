#
# Cookbook Name:: cq
# Recipe:: _jcr_nodes
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

# CREATE
# -----------------------------------------------------------------------------

# Create new node w/o properties
cq_jcr '/content/test1' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"

  action :create
end

# Create new node w/o properties and custom resource name
cq_jcr 'New node at /content/testXYZ' do
  path '/content/testXYZ'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"

  action :create
end

# Create new node w/ some properties
cq_jcr '/content/test2' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'property_one' => 'first',
    'property_two' => 'second',
    'property_three' => 'third'
  )

  action :create
end

# Create new node w/ some properties
cq_jcr '/content/Special_%characters (test)' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'p1' => '100',
    'p2' => '200',
    'p3' => '300'
  )

  action :create
end

# Create action on exsiting node w/o properties (append == true)
cq_jcr '/content/geometrixx/en/events/userconf/jcr:content' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"

  action :create
end

# Create action on existing node w/ some properties (append == true)
cq_jcr '/content/geometrixx/en/company/jcr:content' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'jcr:title' => 'Geometrixx Company'
  )

  action :create
end

# Create action on existing node w/o proeprties (append == false)
cq_jcr '/content/geometrixx/de/support/jcr:content' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  append false

  action :create
end

# Create action on exsiting node w/ properties (append == false)
cq_jcr '/content/geometrixx/en/products/jcr:content' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  append false
  properties(
    'jcr:primaryType' => 'cq:PageContent',
    'jcr:title' => 'New title',
    'subtitle' => 'New subtitle',
    'new_property' => 'Random value'
  )

  action :create
end

# DELETE
# -----------------------------------------------------------------------------

# Delete existing node w/o special characters in its path
cq_jcr '/content/dam/geometrixx-media/articles/en/2012' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"

  action :delete
end

# Delete existing node w/ special characters in its path
cq_jcr '/content/dam/geometrixx-outdoors/products/glasses/Raja Ampat.jpg' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"

  action :delete
end

# Delete not exisitng node
cq_jcr '/path/to/not/exising/node' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"

  action :delete
end

# MODIFY
# -----------------------------------------------------------------------------
# TODO
