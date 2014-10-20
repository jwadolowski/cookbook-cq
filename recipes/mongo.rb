#
# Cookbook Name:: cq
# Recipe:: default
#
# Copyright (C) 2014 Mateusz Los
#
# All rights reserved - Do Not Redistribute
#

include_recipe "mongodb::default"

directory "#{node[:mongodb][:config][:dbpath]}" do
    owner "mongod"
    group "mongod"
    recursive true
end

directory "#{node[:mongodb][:config][:logpath]}" do
    owner "mongod"
    group "mongod"
    recursive true
end

mongodb_instance "mongod"