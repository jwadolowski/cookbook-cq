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
        Chef::Log.error("Resource name: #{new_resource.name}")
        Chef::Log.error("ID: #{new_resource.id}")

        @current_resource = Chef::Resource::CqUser.new(new_resource.id)

        @current_resource.path = user_path
        @current_resource.password_hash = user_password_hash

        # Populate password hash params to class variables
        hash_decoder

        Chef::Log.error("Path: #{current_resource.path}")
        Chef::Log.error("Password hash: #{current_resource.password_hash}")
        Chef::Log.error("Hash algorithm: #{current_resource.hash_algo}")
        Chef::Log.error("Hash salt: #{current_resource.hash_salt}")
        Chef::Log.error("Hash iterations: #{current_resource.hash_iter}")

        Chef::Log.error("Password update required? #{password_update?}")
      end

      def action_modify
      end

      def user_path
        req_path = '/bin/querybuilder.json?path=/home/users&type=rep:User&'\
          "nodename=#{new_resource.id}&p.limit=-1"

        http_resp = http_get(
          new_resource.instance,
          req_path,
          new_resource.username,
          new_resource.password
        )

        parse_querybuilder_response(http_resp.body)
      end

      def parse_querybuilder_response(str)
        hash = json_to_hash(str)

        Chef::Application.fatal!(
          'Query builder returned result set that does not contain just a '\
          'single user'
        ) if hash['hits'].size != 1

        hash['hits'][0]['path']
      end

      def user_password_hash
        req_path = current_resource.path + '.json'

        http_resp = http_get(
          new_resource.instance,
          req_path,
          new_resource.username,
          new_resource.password
        )

        json_to_hash(http_resp.body)['rep:password']
      end

      # All credits goes to Tomasz Rekawek
      #
      # https://gist.github.com/trekawek/9955166
      def hash_decoder
        if current_resource.password_hash =~ /^\{(.+)\}(\w+)-((\d+)-)?(\w+)$/
          @current_resource.hash_algo = $1
          @current_resource.hash_salt = $2
          @current_resource.hash_iter = $4.to_i if $4
        else
          Chef::Application.fatal!('Unsupported hash format!')
        end
      end

      # All credits goes to Tomasz Rekawek
      #
      # https://gist.github.com/trekawek/9955166
      def hash_generator(pass)
        require 'openssl'

        new_hash = (current_resource.hash_salt + pass).bytes
        digest = OpenSSL::Digest.new(current_resource.hash_algo.gsub('-', ''))

        1.upto(current_resource.hash_iter) do
          digest.reset
          digest << new_hash.pack('c*')
          new_hash = digest.to_s.scan(/../).map(&:hex)
        end

        Chef::Log.error("Calculated hash: #{digest.to_s}")

        digest.to_s
      end

      # All credits goes to Tomasz Rekawek
      #
      # https://gist.github.com/trekawek/9955166
      def password_update?
        return false if current_resource.password_hash.end_with?(
          hash_generator(new_resource.user_password)
        )
        true
      end
    end
  end
end
