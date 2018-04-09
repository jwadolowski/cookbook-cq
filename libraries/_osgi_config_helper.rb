#
# Cookbook Name:: cq
# Libraries:: OsgiConfigHelper
#
# Copyright (C) 2018 Jakub Wadolowski
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
    include Cq::OsgiComponentHelper
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
        "Can't download OSGi configurations from AEM!"
      ) unless html.is_a?(Net::HTTPResponse)

      Chef::Application.fatal!(
        "Can't download available OSGi configuratons! Response code: "\
        "#{html.code}, response body: #{html.body}"
      ) if html.code != '200'

      json_to_hash(html.body[/configData\ = (.+);/, 1])
    end

    def regular_pids(configs)
      configs['pids']
    end

    def factory_pids(configs)
      configs['fpids']
    end

    # All instances of given factory PID
    #
    # [
    #   {
    #     "id" => "com.example.com.cf279d-1530-467f-a1bd-6a22bfee13cb",
    #     "bundle_name" => "Adobe Granite Monitoring Support",
    #     "has_config" => true,
    #     "name" => "Adobe Granite Monitor Handler",
    #     "fpid" => "com.adobe.granite.monitoring.impl.ScriptConfigImpl",
    #     "bundle" => 166
    #   },
    #   {
    #     "id" => "com.example.com.b12334-1jrr-421f-a12d-6a23bfxa421",
    #     "bundle_name" => "Adobe Granite Monitoring Support",
    #     "has_config" => true,
    #     "name" => "Adobe Granite Monitor Handler",
    #     "fpid" => "com.adobe.granite.monitoring.impl.ScriptConfigImpl",
    #     "bundle" => 191
    #   }
    # ]
    def factory_instances(fpid, configs)
      regular_pids(configs).select { |c| c['fpid'] == fpid }
    end

    def pid_exist?(pid, list)
      !list.select { |p| p['id'] == pid }.empty?
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
    def config_info(addr, user, password, pid)
      path = '/system/console/configMgr/' + pid
      json = http_post(addr, path, user, password, {})

      Chef::Application.fatal!(
        "Can't download #{pid} configuration! Response code: #{json.code}, "\
        "response body: #{json.body}"
      ) if json.code != '200'

      json_to_hash(json.body)
    end

    # Converts verbose format of properties AEM returns to the one user defined
    # in cq_osgi_config resource
    def pure_properties(info)
      hash = {}

      info['properties'].each do |k, v|
        # Fallback to 'values' if 'value' doesn't exist
        hash[k] = v['value'].nil? ? v['values'] : v['value']
      end

      hash
    end

    # Properties need to be unified to enable easy comparison:
    # * sort and uniq array elements
    # * serialize all values to string, as that doesn't matter from change
    #   point of view (including array elements)
    def unify_properties(properties)
      properties.each do |k, v|
        if v.is_a?(Array)
          properties[k] = v.map(&:to_s)
          properties[k] = v.sort.uniq
        else
          properties[k] = v.to_s
        end
      end
    end

    def object_properties(info)
      unify_properties(pure_properties(info))
    end

    def validate_keyspace(c_prop, n_prop)
      n_prop.each do |k, _v|
        Chef::Log.warn(
          "#{k} is not a valid property key!"
        ) unless c_prop.include?(k)
      end
    end

    # Always use _valid_ properties defined in your resource as a keyspace we
    # will loop thorugh
    def keyspace(c_prop, n_prop)
      n_prop.delete_if { |k, _v| !c_prop.include?(k) }
    end

    def property_diff(c_prop, n_prop, append)
      diff = {}

      keyspace(c_prop, n_prop).each do |k, v|
        # 3 possible scenarios:
        # * array w/ append and new array elements are not included yet
        # * array w/o append and new array != current array
        # * regular string and new value != current value
        if v.is_a?(Array) && append &&
           (c_prop[k] & n_prop[k]).sort != n_prop[k]
          diff[k] = (c_prop[k] | n_prop[k]).sort
        elsif v.is_a?(Array) && !append && c_prop[k] != n_prop[k]
          diff[k] = n_prop[k]
        elsif v.is_a?(String) && c_prop[k] != n_prop[k]
          diff[k] = n_prop[k]
        end
      end

      diff
    end

    def payload_builder(diff)
      static = { 'apply' => true, 'action' => 'ajaxConfigManager' }
      propertylist = { 'propertylist' => diff.keys.join(',') }

      [static, diff, propertylist].inject(:merge)
    end

    # TODO: validate approach
    # * AEM 5.6.1
    # * AEM 6.0.0
    # * AEM 6.1.0 [OK]
    # * AEM 6.2.0
    def update_config(instance, user, pass, info, diff, hc_params)
      req_path = '/system/console/configMgr/' + info['pid']
      payload = payload_builder(diff).merge(
        '$location' => info['bundle_location']
      )

      Chef::Log.debug("POST payload: #{payload}")

      http_resp = http_post(
        instance,
        req_path,
        user,
        pass,
        payload
      )

      validate_response(http_resp, '302')
      osgi_component_stability(instance, user, pass, hc_params)
    end

    def create_config(instance, user, pass, diff, factory_pid, hc_params)
      req_path = '/system/console/configMgr/'\
        '[Temporary PID replaced by real PID upon save]'
      payload = payload_builder(diff).merge('factoryPid' => factory_pid)

      Chef::Log.debug("POST payload: #{payload}")

      http_resp = http_post(
        instance,
        req_path,
        user,
        pass,
        payload
      )

      validate_response(http_resp, '302')
      osgi_component_stability(instance, user, pass, hc_params)
    end

    def delete_config(instance, user, pass, pid, hc_params)
      req_path = '/system/console/configMgr/' + pid
      payload = { 'apply' => 1, 'delete' => 1 }

      http_resp = http_post(
        instance,
        req_path,
        user,
        pass,
        payload
      )

      validate_response(http_resp, '200')
      osgi_component_stability(instance, user, pass, hc_params)
    end

    def validate_response(http_resp, expected_code)
      Chef::Application.fatal!(
        "Got #{http_resp.code}, but expected #{expected_code}"
      ) if http_resp.code != expected_code
    end
  end
end
