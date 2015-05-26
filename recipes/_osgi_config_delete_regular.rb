#
# Cookbook Name:: cq
# Recipe:: _osgi_config_delete_regular
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
  'This is a test recipe and should not be used outside of test kitchen!'
)

# Not exisiting config
osgi_config_wrapper 'not.existing.config.to.delete' do
  properties('key1' => 'val1')
  action :delete
end

# Update existing regular config and delete it afterwards
osgi_config_wrapper 'com.adobe.cq.wcm.launches.impl.LaunchesEventHandler' do
  properties(
    'launches.eventhandler.threadpool.maxsize' => 100,
    'launches.eventhandler.threadpool.priority' => 'MAX'
  )
  action [:create, :delete]
end

# Not forced delete
osgi_config_wrapper 'com.adobe.cq.commerce.impl.promotion.'\
  'PromotionManagerImpl' do
  properties(
    'cq.commerce.promotion.root' => '/random/path'
  )
  action :delete
end

# Forced delete
osgi_config_wrapper 'com.adobe.granite.auth.oauth.impl.TwitterProviderImpl' do
  properties(
    'oauth.provider.id' => 'XYZ'
  )
  force true
  action :delete
end
