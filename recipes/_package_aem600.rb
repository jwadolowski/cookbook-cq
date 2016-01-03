#
# Cookbook Name:: cq
# Recipe:: _package_aem600
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

# Upload new packages
cq_package "#{node['cq']['author']['run_mode']}: Slice 4.2.1 (upload)" do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source 'https://oss.sonatype.org/content/groups/public/com/cognifide/slice'\
    '/slice-assembly/4.2.1/slice-assembly-4.2.1-cq.zip'

  action :upload
end

cq_package "#{node['cq']['author']['run_mode']}: Slice Extension for AEM6 "\
  '(upload)' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source 'https://oss.sonatype.org/content/groups/public/com/cognifide/'\
    'slice-addon/slice-aem60-assembly/1.1.0/slice-aem60-assembly-1.1.0-aem.zip'

  action :upload
end

# Upload already uploaded package
cq_package "#{node['cq']['author']['run_mode']}: Granite Platform Users "\
  '(upload)' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source "http://localhost:#{node['cq']['author']['port']}/etc/packages"\
    '/adobe/granite/com.adobe.granite.platform.users-1.1.4.zip'
  http_user node['cq']['author']['credentials']['login']
  http_pass node['cq']['author']['credentials']['password']

  action :upload
end

# Install new packages (non-recursive)
cq_package "#{node['cq']['author']['run_mode']}: Slice 4.2.1 (install)" do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source 'https://oss.sonatype.org/content/groups/public/com/cognifide/slice'\
    '/slice-assembly/4.2.1/slice-assembly-4.2.1-cq.zip'

  action :install
end

cq_package "#{node['cq']['author']['run_mode']}: Slice Extension for AEM6 "\
  '(install)' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source 'https://oss.sonatype.org/content/groups/public/com/cognifide/'\
    'slice-addon/slice-aem60-assembly/1.1.0/slice-aem60-assembly-1.1.0-aem.zip'

  action :install
end

# Install already installed package
cq_package "#{node['cq']['author']['run_mode']}: CQ Healthcheck (install)" do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source "http://localhost:#{node['cq']['author']['port']}/etc/packages"\
    '/day/cq60/product/cq-healthcheck-content-1.0.12.zip'
  http_user node['cq']['author']['credentials']['login']
  http_pass node['cq']['author']['credentials']['password']

  action :install
end

# Install not yet uploaded package
cq_package "#{node['cq']['author']['run_mode']}: AEM Dash (install)" do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source 'https://github.com/Cognifide/AEM-Dash/releases/download/dash-1.2.0'\
    '/dash-1.2.0-tool.zip'

  action :install
end

# Upload & install (recursive) + reboot
cq_package "#{node['cq']['author']['run_mode']}: Service Pack 2 (upload)" do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source node['cq']['packages']['aem60']['sp2']

  action :upload
end

cq_package "#{node['cq']['author']['run_mode']}: Service Pack 2 (install)" do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source node['cq']['packages']['aem60']['sp2']
  recursive_install true

  action :install

  notifies :restart, 'service[cq60-author]', :immediately
end

# Upload 3 versions of the same package, install 1st and 2nd, but not 3rd
cq_package "#{node['cq']['author']['run_mode']}: ACS AEM Commons 1.10.2" do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source 'https://github.com/Adobe-Consulting-Services/acs-aem-commons'\
    '/releases/download/acs-aem-commons-1.10.2'\
    '/acs-aem-commons-content-1.10.2.zip'

  action :upload
end

cq_package "#{node['cq']['author']['run_mode']}: ACS AEM Commons 1.10.0" do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source 'https://github.com/Adobe-Consulting-Services/acs-aem-commons'\
    '/releases/download/acs-aem-commons-1.10.0'\
    '/acs-aem-commons-content-1.10.0.zip'

  action [:upload, :install]
end

cq_package "#{node['cq']['author']['run_mode']}: ACS AEM Commons 1.9.6" do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source 'https://github.com/Adobe-Consulting-Services/acs-aem-commons'\
    '/releases/download/acs-aem-commons-1.9.6'\
    '/acs-aem-commons-content-1.9.6.zip'

  action [:upload, :install]
end

cq_package "#{node['cq']['author']['run_mode']}: HF 6316" do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source node['cq']['packages']['aem60']['hf6316']
  recursive_install true

  action :deploy

  notifies :restart, 'service[cq60-author]', :immediately
end

cq_package "#{node['cq']['author']['run_mode']}: HF 6167" do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source node['cq']['packages']['aem60']['hf6167']
  recursive_install true

  action :deploy

  notifies :restart, 'service[cq60-author]', :immediately
end

cq_package "#{node['cq']['author']['run_mode']}: HF 6446" do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source node['cq']['packages']['aem60']['hf6446']
  recursive_install true

  action :deploy

  notifies :restart, 'service[cq60-author]', :immediately
end

cq_package "#{node['cq']['author']['run_mode']}: HF 6031" do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source node['cq']['packages']['aem60']['hf6031']
  recursive_install true

  action :deploy

  notifies :restart, 'service[cq60-author]', :immediately
end

# Uninstall Geometrixx package
cq_package "#{node['cq']['author']['run_mode']}: Geometrixx All" do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source "http://localhost:#{node['cq']['author']['port']}/etc/packages"\
    '/day/cq60/product/cq-geometrixx-all-pkg-5.7.476.zip'
  http_user node['cq']['author']['credentials']['login']
  http_pass node['cq']['author']['credentials']['password']

  action :uninstall
end
