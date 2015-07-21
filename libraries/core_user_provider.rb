#
# Cookbook Name:: cq
# Provider:: user
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
    class CqUser < Chef::Provider
      include Cq::Helper

      # Chef 12.4.0 support
      provides :cq_user if Chef::Provider.respond_to?(:provides)

      def whyrun_supported?
        true
      end

      def load_current_resource
      end

      def action_modify
        fail Chef::Exceptions::UnsupportedAction,
             "#{self} does not support :modify"
      end

      def user_path(user, pass)
        req_path = '/bin/querybuilder.json?path=/home/users&type=rep:User&'\
          "nodename=#{new_resource.id}&p.limit=-1"

        http_resp = http_get(
          new_resource.instance,
          req_path,
          user,
          pass
        )

        path_extractor(http_resp.body)
      end

      def path_extractor(str)
        hash = json_to_hash(str)

        Chef::Application.fatal!(
          'Query builder returned result set that does not contain just a '\
          'single user'
        ) if hash['hits'].size != 1

        hash['hits'][0]['path']
      end

      def user_info(user, pass)
        req_path = current_resource.path + '.json'

        http_resp = http_get(
          new_resource.instance,
          req_path,
          user,
          pass
        )

        json_to_hash(http_resp.body)
      end

      # All credits goes to Tomasz Rekawek
      #
      # https://gist.github.com/trekawek/9955166
      def hash_decoder
        hash_params = current_resource.info['rep:password'].match(
          /^\{(?<algo>.+)\}(?<salt>\w+)-(?<iter>(\d+)-)?(?<hash>\w+)$/
        )

        Chef::Application.fatal!('Unsupported hash format!') unless hash_params

        hash_params
      end

      # All credits goes to Tomasz Rekawek
      #
      # https://gist.github.com/trekawek/9955166
      def hash_generator(pass)
        require 'openssl'

        # Get hash parameters
        params = hash_decoder

        algo = params['algo']
        salt = params['salt']
        if params['iter']
          iter = params['iter'].to_i
        else
          iter = 1
        end

        new_hash = (salt + pass).bytes
        digest = OpenSSL::Digest.new(algo.gsub('-', ''))

        1.upto(iter) do
          digest.reset
          digest << new_hash.pack('c*')
          new_hash = digest.to_s.scan(/../).map(&:hex)
        end

        digest.to_s
      end

      # All credits goes to Tomasz Rekawek
      #
      # https://gist.github.com/trekawek/9955166
      def password_update?(new_pass)
        return false if current_resource.info['rep:password'].end_with?(
          hash_generator(new_pass)
        )
        true
      end

      def raw_user_profile(user, pass)
        req_path = current_resource.path + '/profile.json'

        http_resp = http_get(
          new_resource.instance,
          req_path,
          user,
          pass
        )

        json_to_hash(http_resp.body)
      end

      def filter_user_profile(profile)
        keys = %w(jobTitle gender aboutMe phoneNumber mobile street city email
                  state familyName country givenName postalCode)

        profile.delete_if { |k, _v| !keys.include?(k) }
      end

      def normalize_user_profile(profile)
        mappings = {
          'givenName' => 'first_name',
          'familyName' => 'last_name',
          'phoneNumber' => 'phone_number',
          'jobTitle' => 'job_title',
          'postalCode' => 'postal_code',
          'aboutMe' => 'about'
        }

        profile.keys.each do |k|
          profile[mappings[k]] = profile.delete(k) if mappings[k]
        end

        profile
      end

      def user_profile(user, pass)
        profile = raw_user_profile(user, pass)

        normalize_user_profile(
          filter_user_profile(profile)
        )
      end

      def profile_from_attr
        {
          'email' => new_resource.email,
          'first_name' => new_resource.first_name,
          'last_name' => new_resource.last_name,
          'phone_number' => new_resource.phone_number,
          'job_title' => new_resource.job_title,
          'street' => new_resource.street,
          'mobile' => new_resource.mobile,
          'city' => new_resource.city,
          'postal_code' => new_resource.postal_code,
          'country' => new_resource.country,
          'state' => new_resource.state,
          'gender' => new_resource.gender,
          'about' => new_resource.about
        }
      end

      def compacted_profile
        profile_from_attr.delete_if { |_k, v| v.nil? }
      end

      def profile_diff
        diff = {}

        compacted_profile.each do |k, v|
          diff[k] = v if compacted_profile[k] != current_resource.profile[k]
        end

        diff
      end

      def profile_payload_builder
        mappings = {
          'email' => './profile/email',
          'first_name' => './profile/givenName',
          'last_name' => './profile/familyName',
          'phone_number' => './profile/phoneNumber',
          'job_title' => './profile/jobTitle',
          'street' => './profile/street',
          'mobile' => './profile/mobile',
          'city' => './profile/city',
          'postal_code' => './profile/postalCode',
          'country' => './profile/country',
          'state' => './profile/state',
          'gender' => './profile/gender',
          'about' => './profile/aboutMe'
        }

        profile = profile_diff

        profile.keys.each do |k|
          profile[mappings[k]] = profile.delete(k) if mappings[k]
        end

        profile
      end

      def status_update?
        current_resource.enabled != new_resource.enabled
      end

      def status_payload
        if new_resource.enabled
          { 'disableUser' => '' }
        else
          { 'disableUser' => 'inactive' }
        end
      end

      def profile_update(auth_user, auth_pass, new_pass)
        req_path = current_resource.path + '.rw.userprops.html'

        payload = { '_charset_' => 'utf-8' }

        # Add new password if needed
        payload = payload.merge(
          'rep:password' => new_pass,
          ':currentPassword' => auth_pass
        ) if password_update?(new_pass)

        # Update user profile if any change was detected
        payload = payload.merge(
          profile_payload_builder
        ) unless profile_diff.empty?

        # Update user status
        payload = payload.merge(status_payload) if status_update?

        http_post(
          new_resource.instance,
          req_path,
          auth_user,
          auth_pass,
          payload
        )
      end
    end
  end
end
