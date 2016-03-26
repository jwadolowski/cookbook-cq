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

    def extract_jar_content(jar, content, dst)
      cmd_str = "unzip -b -j #{jar} \"#{content}\" -d #{dst}"
      cmd = Mixlib::ShellOut.new(cmd_str)
      cmd.run_command
      cmd.error!

      Chef::Log.debug("Unzip command: #{cmd_str}")
      Chef::Log.debug("JAR file successfully extracted: #{cmd.stdout}")
    rescue => e
      Chef::Application.fatal!("Can't extract content out of JAR file: #{e}")
    end

    # Makes sure the following elements are in place
    #
    # /path/to/chef/cache/crypto
    # ├── Decrypt.class
    # ├── Decrypt.java
    # ├── key
    # │   └── master
    # ├── libs
    # │   ├── aem
    # │   │   ├── com.adobe.granite.crypto-3.0.18-CQ610-B0004.jar
    # │   │   ├── cryptojce-6.0.0.jar
    # │   │   ├── cryptojcommon-6.0.0.jar
    # │   │   ├── jcmFIPS-6.0.0.jar
    # │   │   └── jSafeCryptoSupport.jar
    # │   └── log
    # │       ├── slf4j-api-1.7.12.jar
    # │       └── slf4j-simple-1.7.12.jar
    # └── tmp
    #
    def load_decryptor
      crypto_dir_structure
      deploy_decryptor
    end

    def crypto_dir_structure
      dirs = %w(crypto/key crypto/aem/libs crypto/aem/log crypto/tmp)

      dirs.each do |d|
        path = ::File.join(Chef::Config[:file_cache_path], d)

        directory = Chef::Resource::Directory.new(path, run_context)
        directory.owner('root')
        directory.group('root')
        directory.mode(d == 'crypto/key' ? '0600' : '0755') # keep key secure
        directory.recursive(true)
        directory.run_action(:create)
      end
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
