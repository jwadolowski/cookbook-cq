#
# Cookbook Name:: cq
# Libraries:: CryptoHelper
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

require_relative '_http_helper'

module Cq
  module CryptoHelper
    include Cq::HttpHelper

    def crypto_root_dir
      ::File.join(Chef::Config[:file_cache_path], 'crypto')
    end

    def crypto_tmp_dir
      ::File.join(crypto_root_dir, 'tmp')
    end

    def crypto_aem_dir
      ::File.join(crypto_root_dir, 'libs', 'aem')
    end

    def crypto_log_dir
      ::File.join(crypto_root_dir, 'libs', 'log')
    end

    def crypto_key_dir
      ::File.join(crypto_root_dir, 'key')
    end

    def primary_jar
      ::File.join(
        Chef::Config[:file_cache_path],
        uri_basename(node['cq']['jar']['url'])
      )
    end

    def extract_jar(jar, filter, dst)
      cmd_str = "unzip -o -b -j #{jar} \"#{filter}\" -d #{dst}"
      cmd = Mixlib::ShellOut.new(cmd_str)
      cmd.run_command
      cmd.error!

      Chef::Log.debug("Unzip command: #{cmd_str}")
      Chef::Log.debug("JAR file successfully extracted:\n #{cmd.stdout}")
    rescue => e
      Chef::Application.fatal!("Can't extract content out of JAR file: #{e}")
    end

    # Makes sure the following elements are in place
    #
    # /path/to/chef/cache/crypto
    # |-- Decrypt.class
    # |-- Decrypt.java
    # |-- key
    # |   |-- master
    # |-- libs
    # |   |-- aem
    # |       |-- com.adobe.granite.crypto-3.0.18-CQ610-B0004.jar
    # |       |-- cryptojce-6.0.0.jar
    # |       |-- cryptojcommon-6.0.0.jar
    # |       |-- jcmFIPS-6.0.0.jar
    # |       |-- jSafeCryptoSupport.jar
    # |   |-- log
    # |       |-- slf4j-api-1.7.12.jar
    # |       |-- slf4j-simple-1.7.12.jar
    # |-- tmp
    #
    def load_decryptor
      crypto_dir_structure
      extract_aem_libs
      deploy_decryptor
    end

    def crypto_dir_structure
      dirs = [
        crypto_key_dir,
        crypto_aem_dir,
        crypto_log_dir,
        crypto_tmp_dir
      ]

      dirs.each do |d|
        directory = Chef::Resource::Directory.new(d, run_context)
        directory.owner('root')
        directory.group('root')
        directory.mode(d.end_with?('key') ? '0600' : '0755') # keep key secure
        directory.recursive(true)
        directory.run_action(:create)
      end
    end

    def extract_aem_libs
      aem_libs = ::Dir.entries(crypto_aem_dir)

      if aem_libs.empty? || aem_libs.length != 5
        Chef::Log.debug('Missing crypto AEM libraries. Extracting...')

        # Extract standalone JAR file out of the primary one
        extract_jar(primary_jar, 'static/app/*', crypto_tmp_dir)

        # Crypto tmp dir should contain just a standalone jar file
        tmp_files = ::Dir[::File.join(crypto_tmp_dir, '*')]
        Chef::Log.warn(
          'Crypto tmp directory contains more than 1 file! Only standalone '\
          'JAR file should be there.'
        ) if tmp_files.length > 1
        standalone_jar = tmp_files.first

        # Extract com.adobe.granite.crypto JAR file from standalone one
        extract_jar(
          standalone_jar,
          'resources/install/0/com.adobe.granite.crypto*',
          crypto_aem_dir
        )

        # Remove standalone JAR, as it is no longer needed
        ::File.delete(standalone_jar)

        # Find out filename of com.adobe.granite.crypto file (varies by AEM
        # version)
        granite_crypto_name = ::Dir.entries(
          crypto_aem_dir
        ).find { |f| f.match(/com.adobe.granite.crypto.+/) }
        granite_crypto_jar = ::File.join(crypto_aem_dir, granite_crypto_name)

        # Extract libs out of com.adobe.granite.crypto JAR file
        extract_jar(granite_crypto_jar, 'META-INF/lib/*', crypto_aem_dir)
      end

      Chef::Log.debug('All crypto AEM libraries have been already extracted')
    end

    def deploy_decryptor
      path = ::File.join(
        Chef::Config[:file_cache_path], 'crypto', 'Decrypt.java'
      )

      cookbook_file = Chef::Resource::CookbookFile.new(path, run_context)
      cookbook_file.source('Decrypt.java')
      cookbook_file.owner('root')
      cookbook_file.group('root')
      cookbook_file.mode('0644')
      cookbook_file.cookbook('cq')
      cookbook_file.run_action(:create)

      # TODO: compile_decryptor if cookbook_file.updated_by_last_action?(true)
    end

    def decrypt(str)
    end

    def encrypt(str)
    end
  end
end
