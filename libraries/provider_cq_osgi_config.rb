#
# Cookbook Name:: cq
# Provider:: osgi_config
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
    class CqOsgiConfig < Chef::Provider
      include Cq::OsgiConfigHelper

      provides :cq_osgi_config if Chef::Provider.respond_to?(:provides)

      def whyrun_supported?
        true
      end

      def load_current_resource
        @current_resource = Chef::Resource::CqOsgiConfig.new(new_resource.pid)

        # Unify properties defined in new resource
        @new_resource.properties(unify_properties(new_resource.properties))

        @new_resource.healthcheck_params = healthcheck_params(
          new_resource.rescue_mode,
          new_resource.same_state_barrier,
          new_resource.error_state_barrier,
          new_resource.max_attempts,
          new_resource.sleep_time
        )

        # Fetch all OSGi configs just once
        full_list = config_list(
          new_resource.instance,
          new_resource.username,
          new_resource.password
        )

        if new_resource.factory_pid
          factory_config(full_list)
        else
          regular_config(full_list)
        end
      end

      # -----------------------------------------------------------------------
      # Regular configs
      # -----------------------------------------------------------------------

      def init_regular_current_resource
        @current_resource.info = config_info(
          new_resource.instance,
          new_resource.username,
          new_resource.password,
          new_resource.pid
        )
        Chef::Log.debug("Current resource info: #{current_resource.info}")

        # Extract properties out of info object and unify them
        @current_resource.properties(object_properties(current_resource.info))
        Chef::Log.debug(
          "Current resource properties: #{current_resource.properties}"
        )
      end

      def regular_config(list)
        # Since property check of not existing OSGi configuraton returns proper
        # JSON, we need to look up the entire list first to define wether given
        # config exists or not. This is what AEM returns when there's no
        # defined PID:
        #
        # {
        #   "pid": "not.existing.config.create.1k1v",
        #   "title": "not.existing.config.create.1k1v",
        #   "description": "This form is automatically generated from existing
        #     properties because no property descriptors are available for this
        #     configuration. This may be cause by the absence of the OSGi
        #     Metatype Service or the absence of a MetaType descriptor for this
        #     configuration.",
        #   "properties": {}
        # }
        #
        # Technically we can rely on description, but it can change any time,
        # so let's stick to aforementioned approach
        pid_exists = pid_exist?(new_resource.pid, regular_pids(list))

        if pid_exists
          init_regular_current_resource

          # Validate keys defined in user's resource, warn if there are any
          # redundant ones
          validate_keyspace(
            current_resource.properties,
            new_resource.properties
          )
        else
          Chef::Application.fatal!("#{new_resource.pid} PID does NOT exist!")
        end
      end

      def create_regular_config
        diff = property_diff(
          current_resource.properties,
          new_resource.properties,
          new_resource.append
        )
        Chef::Log.debug("Property diff: #{diff}")

        if new_resource.force || !diff.empty?
          converge_by("Create #{new_resource.pid}") do
            # Calculated diff has precedence over defined properties. This is
            # required to respect append property
            diff = new_resource.properties.merge(
              diff
            ) if new_resource.force || new_resource.apply_all

            # If user specified just a subset of properties the missing ones
            # can be included automatically if needed
            diff = current_resource.properties.merge(
              diff
            ) if new_resource.include_missing

            update_config(
              new_resource.instance,
              new_resource.username,
              new_resource.password,
              current_resource.info,
              diff,
              new_resource.healthcheck_params
            )
          end
        else
          Chef::Log.info("#{new_resource.pid} is already configured")
        end
      end

      def delete_regular_config
        if new_resource.force || !customized_properties.empty?
          converge_by("Delete #{new_resource.pid}") do
            delete_config(
              new_resource.instance,
              new_resource.username,
              new_resource.password,
              new_resource.pid,
              new_resource.healthcheck_params
            )
          end
        else
          Chef::Log.info(
            "All #{new_resource.pid} properties already have default values"
          )
        end
      end

      # -----------------------------------------------------------------------
      # Factory configs
      # -----------------------------------------------------------------------

      def factory_config(list)
        fpid_exists = pid_exist?(new_resource.factory_pid, factory_pids(list))

        if fpid_exists
          init_default_properties

          # Validate keys defined in user's resource, warn if there are any
          # redundant ones
          validate_keyspace(
            current_resource.default_properties,
            new_resource.properties
          )

          init_unique_fields

          # Get list of all instances
          instances = factories_info(
            factory_instances(new_resource.factory_pid, list)
          )

          # Calculate fingerprint (ID) for given config
          @new_resource.fingerprint = my_fingerprint
          Chef::Log.debug("Fingerprint: #{new_resource.fingerprint}")

          # Group existing instances by fingerprint
          @current_resource.fingerprint_groups = group_by_id(instances)
          Chef::Log.debug(
            "Fingerprint groups: #{current_resource.fingerprint_groups}"
          )
        else
          Chef::Application.fatal!(
            "#{new_resource.factory_pid} PID does NOT exist!"
          )
        end
      end

      def init_default_properties
        @current_resource.default_properties = object_properties(
          factory_pid_info
        )
        Chef::Log.debug(
          "Default #{new_resource.factory_pid} properties: " +
          current_resource.default_properties.to_s
        )
      end

      def init_unique_fields
        # By default all fields should be considered as unique, so update
        # unique_fileds property if user didn't set anything explicitly
        @new_resource.unique_fields(
          current_resource.default_properties.keys
        ) if new_resource.unique_fields.empty?
      end

      # Info about factory PID itself (number of properties, their names and
      # default values, etc)
      def factory_pid_info
        config_info(
          new_resource.instance,
          new_resource.username,
          new_resource.password,
          new_resource.factory_pid
        )
      end

      # Calculates ID (fingerprint) for given resource. Fallbacks to default
      # one if user didn't define key that's used in unique_properties
      def my_fingerprint
        new_resource.unique_fields.map do |f|
          if !new_resource.properties[f].nil?
            new_resource.properties[f]
          else
            current_resource.default_properties[f]
          end
        end
      end

      # ID (fingerprint) is defined by unique_fields property
      def group_by_id(instances)
        instances.group_by do |i|
          new_resource.unique_fields.map { |f| i['properties'][f] }
        end
      end

      # [
      #   {
      #     "pid" => "my.factory.pid.example.com-123",
      #     "properties" => { "a" => 100, "b" => 200 },
      #     "bundle_location" => "launchpad:resources/install/1"
      #   },
      #   {
      #     "pid" => "my.factory.pid.example.com-456",
      #     "properties" => { "a" => 31, "b" => 45 },
      #     "bundle_location" => "launchpad:resources/install/2"
      #   }
      # ]
      def factories_info(instances)
        array = []

        instances.each do |i|
          info = config_info(
            new_resource.instance,
            new_resource.username,
            new_resource.password,
            i['id']
          )

          Chef::Log.debug("Factory instance raw info: #{info}")

          array.push(
            'pid' => i['id'],
            'properties' => unify_properties(pure_properties(info)),
            'bundle_location' => info['bundle_location']
          )
        end

        array
      end

      # Add score to each instance of given factory. Score's defined by diff -
      # the lowest score, the better match
      #
      # [
      #   {
      #     "id" => "my.factory.pid.example.com-123",
      #     "properties" => { "a" => 100, "b" => 200 },
      #     "bundle_location" => "launchpad:resources/install/1",
      #     "score" => 3
      #   },
      #   {
      #     "id" => "my.factory.pid.example.com-456",
      #     "properties" => { "a" => 31, "b" => 45 },
      #     "bundle_location" => "launchpad:resources/install/2",
      #     "score" => 2
      #   }
      # ]
      def factory_ranking(instances)
        instances.each do |i|
          diff = property_diff(
            i['properties'],
            new_resource.properties,
            new_resource.append
          )

          i['score'] = diff.length
        end
      end

      def zero_score_instances(rank)
        rank.select { |i| i['score'] == 0 }
      end

      def non_zero_score_instances(rank)
        rank.select { |i| i['score'] != 0 }
      end

      def lowest_score_instances(rank)
        min_score = rank.map { |i| i['score'] }.min
        rank.select { |i| i['score'] == min_score }
      end

      # Input:
      # {
      #   'a' => 1,
      #   'b' => 'xyz'
      #   'c' => [ 'd', 'e', 'f' ]
      # }
      #
      # Output: '1:xyz:d_e_f'
      def property_checksum(properties)
        properties.map { |p| p.is_a?(Array) ? p.join('_') : p }.join(':')
      end

      # Get all modified properties (non default ones)
      def customized_properties
        current_resource.info['properties'].select do |_k, v|
          v['is_set'] == true
        end
      end

      def new_instance_properties
        if new_resource.include_missing
          current_resource.default_properties.merge(new_resource.properties)
        else
          new_resource.properties
        end
      end

      def create_missing_instances(count)
        converge_by(
          "Create #{count} #{new_resource.factory_pid} instance(s)"
        ) do
          count.times do
            create_config(
              new_resource.instance,
              new_resource.username,
              new_resource.password,
              new_instance_properties,
              new_resource.factory_pid,
              new_resource.healthcheck_params
            )
          end
        end
      end

      def delete_redundant_instances(instances)
        converge_by(
          "Delete #{instances.length} #{new_resource.factory_pid} instance(s)"
        ) do
          instances.length.times do |i|
            delete_config(
              new_resource.instance,
              new_resource.username,
              new_resource.password,
              instances[i]['pid'],
              new_resource.healthcheck_params
            )
          end
        end
      end

      def update_existing_instances(instances, diff)
        converge_by(
          "Update #{instances.length} #{new_resource.factory_pid} instance(s)"
        ) do
          # Calculated diff has precedence over defined properties. This is
          # required to respect append property
          diff = new_resource.properties.merge(diff) if new_resource.apply_all

          # Include missing properties from existing instance if needed
          diff = instances.first['properties'].merge(
            diff
          ) if new_resource.include_missing

          instances.each do |i|
            update_config(
              new_resource.instance,
              new_resource.username,
              new_resource.password,
              i,
              diff,
              new_resource.healthcheck_params
            )
          end
        end
      end

      def same_properties?(instances)
        instances.uniq { |c| property_checksum(c) }.length == 1
      end

      def align_same_property_instances(candidates, diff)
        if candidates.length == new_resource.count
          update_existing_instances(candidates, diff)
        elsif candidates.length < new_resource.count
          update_existing_instances(candidates, diff)
          create_missing_instances(new_resource.count - candidates.length)
        elsif candidates.length > new_resource.count
          if new_resource.enforce_count
            count = candidates.length - new_resource.count

            delete_redundant_instances(candidates[0..count - 1])
            update_existing_instances(candidates[count..-1], diff)
          else
            Chef::Application.fatal!(
              "Expected #{new_resource.count} #{new_resource.factory_pid} "\
              "instance(s), but found #{candidates.length} possible "\
              'candidates. enforce_count is off, so please either turn it '\
              'on or update unique_fields property'
            )
          end
        end
      end

      def zero_score_factories(copies)
        if copies.length == new_resource.count
          Chef::Log.info("#{new_resource.factory_pid} is already configured")
        elsif copies.length < new_resource.count
          create_missing_instances(new_resource.count - copies.length)
        elsif copies.length > new_resource.count
          if new_resource.enforce_count
            count = copies.length - new_resource.count
            delete_redundant_instances(copies[0..count - 1])
          else
            Chef::Application.fatal!(
              "Expected #{new_resource.count} #{new_resource.factory_pid} "\
              "instance(s), but found #{copies.length} of them. "\
              'enforce_count is off, so please either turn it on to '\
              'get rid of redundant configs or update unique_fields property'
            )
          end
        end
      end

      def non_zero_score_factories(rank)
        # Get lowest score instances out of non-zero score ones
        candidates = lowest_score_instances(non_zero_score_instances(rank))
        Chef::Log.debug("Lowest (non-zero) score instances: #{candidates}")

        # All candidates are identical (have the same properties)
        if same_properties?(candidates)
          # Since all candidates are the same use the fist one as a diff source
          diff = property_diff(
            candidates.first['properties'],
            new_resource.properties,
            new_resource.append
          )
          Chef::Log.debug("Diff: #{diff}")

          if diff.empty?
            Chef::Log.info("#{new_resource.factory_pid} is already configured")
          else
            align_same_property_instances(candidates, diff)
          end
        else
          Chef::Application.fatal!(
            'Given set of unique fields has a few similar instances: '\
            "#{candidates}. Unfortunately, even though they have the "\
            "same number of different properties, it's not possible to "\
            'determine which ones of them should be taken into '\
            'consideration. Please redefine your unique properties'
          )
        end
      end

      def align_factory_twins(twins)
        rank = factory_ranking(twins)
        Chef::Log.debug("Ranking: #{rank}")

        # Look for exact copies of given config (score == 0)
        ideal_copies = zero_score_instances(rank)

        if !ideal_copies.empty?
          zero_score_factories(ideal_copies)
        else
          non_zero_score_factories(rank)
        end
      end

      def create_factory_config
        # All configs that have the same fingerprint (ID)
        twins = current_resource.fingerprint_groups[new_resource.fingerprint]
        Chef::Log.debug("Instances with the same fingerprint: #{twins}")

        # Found some configs with the same fingerprint
        if !twins.nil?
          align_factory_twins(twins)
        else
          converge_by(
            "Create #{new_resource.count} new instance(s) of " +
            new_resource.factory_pid
          ) do
            new_resource.count.times do
              create_config(
                new_resource.instance,
                new_resource.username,
                new_resource.password,
                new_instance_properties,
                new_resource.factory_pid,
                new_resource.healthcheck_params
              )
            end
          end
        end
      end

      def delete_factory_config
        twins = current_resource.fingerprint_groups[new_resource.fingerprint]
        Chef::Log.debug("Instances with the same fingerprint: #{twins}")

        if !twins.nil?
          twins.each do |t|
            converge_by("Delete #{t['pid']}") do
              delete_config(
                new_resource.instance,
                new_resource.username,
                new_resource.password,
                t['pid'],
                new_resource.healthcheck_params
              )
            end
          end
        else
          Chef::Log.info(
            "All instances of #{new_resource.factory_pid} with "\
            "#{new_resource.fingerprint} fingerprint have been already deleted"
          )
        end
      end

      # -----------------------------------------------------------------------
      # Actions
      # -----------------------------------------------------------------------

      def action_create
        if new_resource.factory_pid
          create_factory_config
        else
          create_regular_config
        end
      end

      def action_delete
        if new_resource.factory_pid
          delete_factory_config
        else
          delete_regular_config
        end
      end
    end
  end
end
