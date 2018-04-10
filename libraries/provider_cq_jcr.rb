#
# Cookbook Name:: cq
# Provider:: jcr
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

class Chef
  class Provider
    class CqJcr < Chef::Provider
      include Cq::HttpHelper
      include Cq::CryptoHelper

      provides :cq_jcr if Chef::Provider.respond_to?(:provides)

      def whyrun_supported?
        true
      end

      def load_current_resource
        @current_resource = Chef::Resource::CqJcr.new(new_resource.path)

        @raw_node_info = raw_node_info
        @current_resource.exist = exist?(@raw_node_info)

        Chef::Log.debug("Raw node info: #{@raw_node_info.body}")
        Chef::Log.debug("Exists? #{current_resource.exist}")

        if current_resource.exist
          @current_resource.properties(
            standardize_properties(node_info(@raw_node_info))
          )
        end

        Chef::Log.debug(
          'Standardized properties of current resource: ' +
          current_resource.properties.to_s
        )

        if new_resource.properties
          @new_resource.properties(
            standardize_properties(new_resource.properties)
          )
        end

        Chef::Log.debug(
          'Standardized properties of new resource: ' +
          new_resource.properties.to_s
        )
      end

      def action_create
        if !current_resource.exist
          converge_by("Create #{new_resource.path} node") do
            update_via_sling(new_resource.properties)
          end
        else
          apply_update
        end
      end

      def action_delete
        if current_resource.exist
          converge_by("Delete #{new_resource.path} node") do
            delete_node
          end
        else
          Chef::Log.warn(
            "Node #{new_resource.path} does not exist, so can't be deleted!"
          )
        end
      end

      def action_modify
        if current_resource.exist
          apply_update
        else
          Chef::Log.warn("Node #{new_resource.path} does not exist!")
        end
      end

      # TODO: move to misc helper module, as the same has been defined in
      # package helper
      def sleep_time(attempt)
        1 + (2**attempt) + rand(2**attempt)
      end

      def delete_by_post
        http_multipart_post(
          new_resource.instance,
          new_resource.path,
          new_resource.username,
          new_resource.password,
          ':operation' => 'delete'
        )
      end

      def delete_by_delete
        http_delete(
          new_resource.instance,
          new_resource.path,
          new_resource.username,
          new_resource.password
        )
      end

      def delete_node
        max_attempts ||= 3
        attempt ||= 1
        delete_fallback ||= false

        resp = delete_fallback ? delete_by_delete : delete_by_post

        unless resp.is_a?(Net::HTTPResponse)
          raise(Net::HTTPUnknownResponse, 'Unknown HTTP response')
        end

        unless resp.code.start_with?('20')
          raise(Net::HTTPBadResponse, "#{resp.code} error")
        end
      rescue => e
        if (attempt += 1) <= max_attempts
          t = sleep_time(attempt)
          Chef::Log.error(
            "[#{attempt}/#{max_attempts}] Unable to delete node, retrying in "\
            "#{t}s (reason: #{e})"
          )
          sleep(t)
          retry
        elsif delete_fallback == false
          Chef::Log.error(
            "Delete by POST didn't work after #{max_attempts} attempts. "\
            'Retrying using DELETE approach...'
          )
          delete_fallback = true
          attempt = 1
          retry
        else
          Chef::Application.fatal!(
            "Giving up, unable to delete #{new_resource.path} node!"
          )
        end
      end

      def apply_update
        payload = properties_diff

        if payload.empty?
          Chef::Log.info(
            "#{new_resource.path} node is already configured as defined"
          )
        else
          converge_by("Update #{new_resource.path} node") do
            update_via_sling(payload)
          end
        end
      end

      # To make comparison easier sort and uniq all arrays in properties hash
      #
      # By default ['a', 'b'] != ['b', 'a'], hence it's required
      def standardize_properties(hash)
        hash.each do |k, v|
          hash[k] = v.sort.uniq if v.is_a?(Array)
        end

        hash
      end

      def raw_node_info
        req_path = "#{new_resource.path}.json"

        http_get(
          new_resource.instance,
          req_path,
          new_resource.username,
          new_resource.password
        )
      end

      def exist?(http_resp)
        return true if http_resp.code == '200'
        false
      end

      def node_info(http_resp)
        json_to_hash(http_resp.body)
      end

      def merged_new_resource_properties
        current_resource.properties.merge(
          new_resource.properties
        ) do |_key, oldval, newval|
          if oldval.is_a?(Array)
            (oldval + newval).sort.uniq
          else
            newval
          end
        end
      end

      def update_via_sling(payload)
        unless valid_encrypted_fields.empty?
          payload = crypto_payload(payload)

          Chef::Log.debug(
            "Payload passed thorugh crypto processing: #{payload}"
          )
        end

        http_resp = http_multipart_post(
          new_resource.instance,
          new_resource.path,
          new_resource.username,
          new_resource.password,
          payload
        )

        http_response_validator(http_resp)
      end

      def http_response_validator(http_resp)
        return if http_resp.code.start_with?('20')

        Chef::Application.fatal!(
          "Something went wrong during operation on #{new_resource.path}\n"\
          "HTTP response code: #{http_resp.code}\n"\
          "HTTP response body: #{http_resp.body}\n"\
          'Please check error.log file to get more info.'
        )
      end

      def regular_diff
        diff = {}

        merged_new_resource_properties.each do |k, v|
          diff[k] = v if current_resource.properties[k] != v
        end

        diff
      end

      # Sling documentation says that jcr:lastModified and jcr:lastModifiedBy
      # are created automatically, but but I haven't seen them in CQ/AEM.
      # Instead cq:lastModified and cq:lastModified are created. Just in case I
      # decided to exclude both.
      #
      # http://sling.apache.org/documentation/bundles/manipulating-content-the-
      # slingpostservlet-servlets-post.html#automatic-property-values-last-
      # modified-and-created-by
      def auto_properties
        %w(
          jcr:created
          jcr:createdBy
          jcr:lastModified
          jcr:lastModifiedBy
          cq:lastModified
          cq:lastModifiedBy
        )
      end

      # Get protected properties of given JCR node type
      def protected_properties(type)
        return {} if type.nil? || type.empty?

        req_path = "/jcr:system/jcr:nodeTypes/#{type}.json"

        http_resp = http_get(
          new_resource.instance,
          req_path,
          new_resource.username,
          new_resource.password
        )

        protected_properties = json_to_hash(
          http_resp.body
        )['rep:protectedProperties']

        # There is no 'rep:protectedProperties' element in CQ 5.6.1 under
        # /jcr:system/jcr:nodeTypes/<type>.json but jcr:primaryType can be
        # always assumed as protected
        protected_properties = ['jcr:primaryType'] if protected_properties.nil?

        # Even though jcr:primaryType is protected for most types (if not
        # all) it can be updated w/o any issues. It gets deleted from
        # protected properties only if it's explicitly specified in
        # new_resource properties
        if new_resource.properties.include?('jcr:primaryType')
          protected_properties = protected_properties.delete_if do |k, _v|
            k == 'jcr:primaryType'
          end
        end

        protected_properties
      end

      # Get jcr:primaryType from (order matters):
      # * new resource (if defined)
      # * current resource (in case of existing resource update)
      #
      # Return nil if none of above is possible (completely new JCR node)
      def best_primary_type
        primary_types = [
          new_resource.properties['jcr:primaryType'],
          current_resource.properties['jcr:primaryType'],
        ]

        primary_types.each do |t|
          return t if t
        end

        nil
      end

      # Check whether given property is editable
      def editable_property(name)
        # Get protected properties of given JCR type. Has to be fetched just
        # once
        @protected_properties ||= protected_properties(best_primary_type)

        !auto_properties.include?(name) &&
          !@protected_properties.include?(name)
      end

      def force_replace_diff
        diff = {}

        # Iterate over desired (new) properties first to see if update is
        # required
        new_resource.properties.each do |k, v|
          diff[k] = v if current_resource.properties[k] != v
        end

        # Mark for deletion all properties that are currently present, but are
        # not defined in desired (new) state
        current_resource.properties.each do |k, _v|
          diff["#{k}@Delete"] = '' unless new_resource.properties[k]
        end

        diff
      end

      def properties_diff
        diff = {}

        unless new_resource.properties.empty?
          diff = if new_resource.append
                   regular_diff
                 else
                   force_replace_diff
                 end

          # Get rid of keys (properties) that are protected or automatically
          # created
          diff.delete_if do |k, _v|
            !editable_property(k.gsub(/@Delete/, ''))
          end

          # Handle encrypted fields
          diff = crypto_payload(diff) unless valid_encrypted_fields.empty?
        end

        Chef::Log.debug("Properties diff: #{diff}")

        diff
      end

      # There's no point to bother about:
      # * fields specified in encrypted_fileds property, but not present in
      #   new_resource.properties
      # * non string values
      def valid_encrypted_fields
        fields = []

        new_resource.encrypted_fields.each do |f|
          property = new_resource.properties[f]

          if property && property.is_a?(String)
            fields.push(f)
          else
            Chef::Log.warn(
              "Ignoring #{f}, as it's not present in both places "\
              '(encrypted_fields and properties) or is not a String'
            )
          end
        end

        Chef::Log.debug("Valid encrypted fields: #{fields}")

        fields
      end

      # Encrypts value if decrypt(current_value) != new_value. If these two
      # elements match then such item is removed from payload, as there's no
      # reason to do any changes on it.
      #
      # Returns modified payload
      def crypto_payload(payload)
        load_decryptor

        key = load_master_key(
          new_resource.instance,
          new_resource.username,
          new_resource.password
        )

        begin
          valid_encrypted_fields.each do |f|
            current_val = current_resource.properties[f]
            new_val = new_resource.properties[f]

            if current_val && decrypt(key, current_val) == new_val
              payload.delete(f)
            else
              payload[f] = encrypt(
                new_resource.instance,
                new_resource.username,
                new_resource.password,
                new_val
              )
            end
          end
        ensure
          unload_master_key(key)
        end

        payload
      end
    end
  end
end
