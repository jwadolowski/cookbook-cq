#
# Cookbook Name:: cq
# Recipe:: _osgi_config_create_regular
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

# * Regular (not-factory) configurations
# -----------------------------------------------------------------------------

# ** 1 key, 1 value
# *** append: [0,1], valid: 0
osgi_config_wrapper 'com.day.cq.dam.s7dam.common.'\
  'S7damDamChangeEventListener' do
  properties('cq.dam.s7dam.damchangeeventlistener.enabled' => false)
end
# *** append: [0,1], valid: 1
osgi_config_wrapper 'com.day.cq.dam.scene7.impl.'\
  'Scene7ConfigurationEventListener' do
  properties('cq.dam.scene7.configurationeventlistener.enabled' => true)
end

# ** 1 key, N values
# *** existing: 0, append: [0,1], valid: [0,1]
osgi_config_wrapper 'not.existing.config.create.1kNv' do
  properties('key1' => %w(val1 val2 val3))
end
# *** append: 0, valid: 0
osgi_config_wrapper 'com.day.cq.wcm.foundation.impl.'\
  'AdaptiveImageComponentServlet' do
  properties('adapt.supported.widths' => %w(325 480 476 620 720))
  append false
end
# *** append: 0, valid: 1
osgi_config_wrapper 'com.adobe.cq.media.publishing.dps.impl.contentsync.'\
  'DPSPagesUpdateHandler' do
  properties(
    'cq.pagesupdatehandler.imageresourcetypes' =>
     ['foundation/components/image']
  )
  append false
end
# *** append: 1, valid: 0
osgi_config_wrapper 'com.adobe.cq.media.publishing.dps.impl.contentsync.'\
  'DPSSubPagesUpdateHandler' do
  properties(
    'cq.pagesupdatehandler.imageresourcetypes' =>
     ['test/append/value']
  )
  append true
end
# *** append: 1, valid: 1
osgi_config_wrapper 'com.day.cq.dam.scene7.impl.'\
  'Scene7AssetMimeTypeServiceImpl' do
  properties(
    'cq.dam.scene7.assetmimetypeservice.mapping' => ['Image=image/jpeg']
  )
  append true
end

# ** N key, N values
# *** existing: 0, append: [0,1], valid: [0,1]
osgi_config_wrapper 'not.existing.config.create.NkNv' do
  properties('key1' => 'val1', 'key2' => %w(a b c))
end
# *** append: 0, valid: 0
osgi_config_wrapper 'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl' do
  properties(
    'scheduler.period' => 5,
    'scheduler.concurrent' => false,
    'service.bad_link_tolerance_interval' => '24',
    'service.check_override_patterns' => ['^system/'],
    'service.cache_broken_internal_links' => true,
    'service.special_link_prefix' => ['javascript:',
                                      'data:',
                                      'mailto:',
                                      'rx:',
                                      '#',
                                      '<!--',
                                      '${',
                                      'z:'],
    'service.special_link_patterns' => ''
  )
  append false
end

osgi_config_wrapper 'com.day.cq.dam.core.impl.servlet.HealthCheckServlet' do
  properties(
    'sling.servlet.paths' => '/libs/dam/health_check',
    'sling.servlet.methods' => ['GET', 'POST', 'CUSTOM', '-stop', '-i NJECT'],
    'sling.servlet.extensions' => 'json',
    'cq.dam.sync.workflow.id' => '/some/path/to/model',
    'cq.dam.sync.folder.types' => ['sth',
                                   '-u Z',
                                   '-uZ',
                                   '-u',
                                   '-p Y',
                                   '-pY',
                                   '-p',
                                   '-i X',
                                   '-iX',
                                   '-i']
  )
  append false
end
# *** append: 0, valid: 1
osgi_config_wrapper 'com.adobe.mac.core.impl.DAMVolumeChecker' do
  properties(
    'scheduler.expression' => '0 0 0 * * ?',
    'damRootPath' => '/content/dam/mac/',
    'sizeThreshold' => '500',
    'countThreshold' => 1000,
    'recipients' => []
  )
  append false
end
# *** append: 1, valid: 0
osgi_config_wrapper 'org.apache.felix.eventadmin.impl.EventAdmin' do
  properties(
    'org.apache.felix.eventadmin.IgnoreTimeout' => ['com.example*'],
    'not.existing.key' => 'value1'
  )
  append true
end
# *** append: 1, valid: 1
osgi_config_wrapper 'org.apache.sling.engine.impl.SlingMainServlet' do
  properties(
    'sling.max.inclusions' => 50
  )
  append true
end
