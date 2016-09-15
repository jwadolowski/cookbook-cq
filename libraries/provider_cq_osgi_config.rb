#
# Cookbook Name:: cq
# Provider:: osgi_config
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
        Chef::Log.debug(
          "Unified new resource properties: #{new_resource.properties}"
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

      def regular_config(list)
        # Since property check of not existing OSGi configuraton returns proper
        # JSON we need to look up the entire list first to define wether given
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
        regular_pids = regular_pids(list)
        pid_exists = pid_exist?(new_resource.pid, regular_pids)

        Chef::Log.debug("#{new_resource.pid} exists? #{pid_exists}")

        if pid_exists
          @current_resource.info = config_info(
            new_resource.instance,
            new_resource.username,
            new_resource.password,
            new_resource.pid
          )

          Chef::Log.debug("Current resource info: #{current_resource.info}")

          # Extract properties out of info object and unify them
          @current_resource.properties(
            unify_properties(
              pure_properties(current_resource.info)
            )
          )

          # Validate keys defined in user's resource, warn if there are any
          # redundant ones
          validate_keyspace(
            current_resource.properties,
            new_resource.properties
          )
        else
          Chef::Application.fatal!("#{new_resource.pid} PID does NOT exist!")
        end

        Chef::Log.debug(
          "Current resource properties: #{current_resource.properties}"
        )
      end

      def factory_config(list)
        factory_pids = factory_pids(list)
        fpid_exists = pid_exist?(new_resource.factory_pid, factory_pids)

        Chef::Log.debug("#{new_resource.factory_pid} exists? #{fpid_exists}")

        if fpid_exists
          @current_resource.default_properties =
            unify_properties(pure_properties(factory_pid_info))
          Chef::Log.debug(
            "Default #{new_resource.factory_pid} properties: "\
            "#{current_resource.default_properties}"
          )

          # Validate keys defined in user's resource, warn if there are any
          # redundant ones
          validate_keyspace(
            current_resource.default_properties,
            new_resource.properties
          )

          # By default all fields should be considered as unique, so fill that
          # in if user didn't set anything explicitly
          @new_resource.unique_fields(
            current_resource.default_properties.keys
          ) if new_resource.unique_fields.empty?
          Chef::Log.debug("Unique fields: #{new_resource.unique_fields}")

          # Get list of all instances
          instances = factories_info(
            factory_instances(new_resource.factory_pid, list)
          )
          Chef::Log.debug(
            "#{new_resource.factory_pid} instances: #{instances}"
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
      def customized_properties(info)
        info['properties'].select { |k, v| v['is_set'] == true }
      end

      def zero_score_factories(ideal_copies)
        case
        when ideal_copies.length == new_resource.count
          Chef::Log.info("#{new_resource.factory_pid} is already configured")
        when ideal_copies.length < new_resource.count
          # Create missing instances
          missing_count = new_resource.count - ideal_copies.length

          converge_by(
            "Create #{missing_count} #{new_resource.factory_pid} instance(s)"
          ) do
            missing_count.times do
              create_config(
                new_resource.instance,
                new_resource.username,
                new_resource.password,
                new_resource.properties,
                new_resource.factory_pid
              )
            end
          end
        when ideal_copies.length > new_resource.count
          # Delete redundant instances if enforce_count is enabled
          if new_resource.enforce_count
            to_delete = ideal_copies.length - new_resource.count

            converge_by(
              "Delete #{to_delete} #{new_resource.factory_pid} instance(s) "\
              'due to enforce_count'
            ) do
              to_delete.times do |i|
                delete_config(
                  new_resource.instance,
                  new_resource.username,
                  new_resource.password,
                  ideal_copies[i]['pid']
                )
              end
            end
          else
            Chef::Application.fatal!(
              "#{new_resource.count} instance(s) of "\
              "#{new_resource.factory_pid} is/are expected, but found "\
              "#{ideal_copies.length} of them. enforce_count is off, so "\
              'please either turn it on to get rid of redundant configs or '\
              'update unique_fields property'
            )
          end
        end
      end

      def greater_than_zero_score_factories(rank)
        # Get lowest score instances out of non-zero score ones
        candidates = lowest_score_instances(non_zero_score_instances(rank))
        Chef::Log.debug("Lowest (non-zero) score instances: #{candidates}")

        # All candidates are identical (have the same properties)
        if candidates.uniq { |c| property_checksum(c) }.length == 1
          diff = property_diff(
            candidates.first['properties'],
            new_resource.properties,
            new_resource.append
          )
          Chef::Log.debug("Diff: #{diff}")

          if diff.empty?
            Chef::Log.info("#{new_resource.factory_pid} is already configured")
          else
            case
            when candidates.length == new_resource.count
              converge_by(
                "Update #{new_resource.count} instance(s) of "\
                "#{new_resource.factory_pid}"
              ) do
                diff = new_resource.properties if new_resource.apply_all
                candidates.each do |c|
                  update_config(
                    new_resource.instance,
                    new_resource.username,
                    new_resource.password,
                    c,
                    diff
                  )
                end
              end
            when candidates.length < new_resource.count
              # Update existing instances
              converge_by(
                "Update #{candidates.length} instance(s) of "\
                "#{new_resource.factory_pid}"
              ) do
                diff = new_resource.properties if new_resource.apply_all
                candidates.each do |c|
                  update_config(
                    new_resource.instance,
                    new_resource.username,
                    new_resource.password,
                    c,
                    diff
                  )
                end
              end

              # Create missing instances
              missing_count = new_resource.count - candidates.length

              converge_by(
                "Create #{missing_count} instance(s) of "\
                "#{new_resource.factory_pid}"
              ) do
                missing_count.times do
                  create_config(
                    new_resource.instance,
                    new_resource.username,
                    new_resource.password,
                    new_resource.properties,
                    new_resource.factory_pid
                  )
                end
              end
            when candidates.length > new_resource.count
              if new_resource.enforce_count
                # Remove redundant configs
                to_delete = candidates.length - new_resource.count

                converge_by(
                  "Delete #{to_delete} instances of "\
                  "#{new_resource.factory_pid} due to enforce_count"
                ) do
                  to_delete.times do |i|
                    delete_config(
                      new_resource.instance,
                      new_resource.username,
                      new_resource.password,
                      candidates[i]['pid']
                    )
                  end
                end

                # Update those that left
                converge_by(
                  "Update #{new_resource.count} instance(s) of "\
                  "#{new_resource.factory_pid}"
                ) do
                  diff = new_resource.properties if new_resource.apply_all
                  new_resource.count.times do |i|
                    update_config(
                      new_resource.instance,
                      new_resource.username,
                      new_resource.password,
                      candidates[i + to_delete],
                      diff
                    )
                  end
                end
              else
                Chef::Application.fatal!(
                  "#{new_resource.count} instance(s) of "\
                  "#{new_resource.factory_pid} is/are expected, but "\
                  "found #{candidates.length} possible candidates. "\
                  'enforce_count is off, so please either turn it on to '\
                  'get rid of redundant configs or update unique_fields '\
                  'property'
                )
              end
            end
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

      def create_regular_config
        diff = property_diff(
          current_resource.properties,
          new_resource.properties,
          new_resource.append
        )
        Chef::Log.debug("Property diff: #{diff}")

        if diff.empty?
          Chef::Log.info("#{new_resource.pid} is already configured")
        else
          converge_by("Create #{new_resource.pid}") do
            diff = new_resource.properties if new_resource.apply_all
            update_config(
              new_resource.instance,
              new_resource.username,
              new_resource.password,
              current_resource.info,
              diff
            )
          end
        end
      end

      def create_factory_config
        # All configs that have the same fingerprint (ID)
        twins = current_resource.fingerprint_groups[new_resource.fingerprint]
        Chef::Log.debug("Instances with the same fingerprint: #{twins}")

        # Found some configs with the same fingerprint
        if !twins.nil?
          rank = factory_ranking(twins)
          Chef::Log.debug("Ranking: #{rank}")

          # Look for exact copies of given config (score == 0)
          ideal_copies = zero_score_instances(rank)

          if !ideal_copies.empty?
            zero_score_factories(ideal_copies)
          else
            greater_than_zero_score_factories(rank)
          end
        else
          converge_by(
            "Create #{new_resource.count} new instance(s) of "\
            "#{new_resource.factory_pid}"
          ) do
            new_resource.count.times do
              create_config(
                new_resource.instance,
                new_resource.username,
                new_resource.password,
                new_resource.properties,
                new_resource.factory_pid
              )
            end
          end
        end
      end

      def action_create
        if new_resource.factory_pid
          create_factory_config
        else
          create_regular_config
        end
      end

      def action_delete
        if  new_resource.factory_pid
          # TODO: factory_instance delete
        else
          if customized_properties(current_resource.info).empty?
            Chef::Log.info(
              "All #{new_resource.pid} properties already have default values"
            )
          else
            converge_by("Delete #{new_resource.pid}") do
              delete_config(
                new_resource.instance,
                new_resource.username,
                new_resource.password,
                new_resource.pid
              )
            end
          end
        end
      end
    end
  end
end
