#
# Cookbook Name:: cq
# Libraries:: OsgiConfigHelper
#
# Copyright (C) 2016 Jakub Wadolowski
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

module Cq
  module OsgiConfigHelper
    include Cq::HttpHelper

    # {
    #   "fpids": [
    #     {
    #       "id": "com.cognifide.factory.x.y.z",
    #       "name": "XYZ description"
    #     },
    #     {
    #       "id": "com.cognifide.factory.a.b.c",
    #       "name": "ABC description"
    #     }
    #   ],
    #   "pids": [
    #     {
    #       "id": "com.cognifide.example.app",
    #       "name": "Example app description"
    #     },
    #     {
    #       "id": "com.cognifide.1.2.3",
    #       "name": "Config 123 description"
    #     }
    #   ]
    # }
    def config_list(addr, user, password)
      html = http_get(addr, '/system/console/configMgr', user, password)
      Chef::Application.fatal!(
        "Can't download available OSGi configuratons! Response code: "\
        "#{html.code}, response body: #{html.body}"
      ) if html.code != '200'

      json_to_hash(html.body[/configData\ = (.+);/,1])
    end

    def matching_pids(configs)
      configs['pids'].select { |c| c['id'] == pid }
    end

    def matching_fpids(configs)
      configs['fpids'].select { |c| c['id'] == fpid }
    end

    # [
    #   {
    #     "pid": "com.cognifide.project.a.b.c.d",
    #     "title": "A title",
    #     "description": "A description",
    #     "properties": {
    #       "path": {
    #         "name": "Path",
    #         "optional": false,
    #         "is_set": true,
    #         "type": "1",
    #         "value": "/path/to/something",
    #         "description": "Some description"
    #       },
    #       "mappings": {
    #         "name": "Path mappings",
    #         "optional": false,
    #         "is_set": true,
    #         "type": "1",
    #         "values": [
    #           "/path/to/resourceA:/resA",
    #           "/path/to/resourceB:/resB"
    #         ],
    #         "description": "Some description"
    #       }
    #     },
    #     "bundleLocation": "Location info",
    #     "bundle_location": "launchpad:resources/install/0/project.jar",
    #     "service_location": "..."
    #   }
    # ]
    def config_properties(addr, user, password, pid)
      path = '/system/console/configMgr/' + pid + '.json'
      json = http_get(addr, path, user, password)

      Chef::Application.fatal!(
        "Can't download #{pid} configuration! Response code: #{json.code}, "\
        "response body: #{html.body}"
      ) if json.code != '200'

      json_to_hash(json.body)
    end

    def factory_instances(configs)
      configs['pids'].select { |c| c['fpid'] == fpid }
    end
  end
end
