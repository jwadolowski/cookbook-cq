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

    # Combines:
    # * current dir (java commands are executed from crypto root dir)
    # * crypto tmp dir (needs to be there, as master key is fetched from
    #   classpath)
    # * all AEM libs (JAR files)
    # * all log libs (JAR files)
    def crypto_classpath
      [
        '.',
        crypto_tmp_dir,
        ::File.join(crypto_aem_dir, '*'),
        ::File.join(crypto_log_dir, '*')
      ].join(':')
    end

    def primary_jar
      ::File.join(
        Chef::Config[:file_cache_path],
        uri_basename(node['cq']['jar']['url'])
      )
    end

    # Path to Decrypt file (w/o extension)
    def decryptor_path
      ::File.join(crypto_root_dir, 'Decrypt')
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
      download_log_libs
      deploy_decryptor

      # Recompile Decrypt.java if cookbook_file's postprocessing didn't finish
      # successfully or wasn't triggered at all as Decrypt.java was already in
      # place
      compile_decryptor unless File.exist?(decryptor_path + '.class')
    end

    def crypto_dir_structure
      dirs = [
        crypto_aem_dir,
        crypto_log_dir,
        crypto_tmp_dir
      ]

      dirs.each do |d|
        directory = Chef::Resource::Directory.new(d, run_context)
        directory.owner('root')
        directory.group('root')
        directory.mode('0755')
        directory.recursive(true)
        directory.run_action(:create)
      end
    end

    def extract_aem_libs
      aem_libs = ::Dir[::File.join(crypto_aem_dir, '*')]

      Chef::Log.debug("Existing AEM libs: #{aem_libs}")

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

      Chef::Log.debug('All AEM crypto libraries are in place')
    end

    def download_log_libs
      server_url = 'http://central.maven.org/maven2'

      log_libs = {
        '/org/slf4j/slf4j-api/1.7.12/slf4j-api-1.7.12.jar' =>
          '0aee9a77a4940d72932b0d0d9557793f872e66a03f598e473f45e7efecdccf99',
        '/org/slf4j/slf4j-simple/1.7.12/slf4j-simple-1.7.12.jar' =>
          'ff15e390d71e9852c296fb63986995609dc8c6681f9eff45ef65281a94649acd'
      }

      log_libs.each do |k, v|
        url = server_url + k
        filename = uri_basename(url)
        path = ::File.join(crypto_log_dir, filename)

        remote_file = Chef::Resource::RemoteFile.new(path, run_context)
        remote_file.source(url)
        remote_file.mode('0644')
        remote_file.use_conditional_get(false)
        remote_file.checksum(v)
        remote_file.backup(false)
        remote_file.run_action(:create)
      end
    end

    def deploy_decryptor
      path = decryptor_path + '.java'

      cookbook_file = Chef::Resource::CookbookFile.new(path, run_context)
      cookbook_file.source('Decrypt.java')
      cookbook_file.owner('root')
      cookbook_file.group('root')
      cookbook_file.mode('0644')
      cookbook_file.cookbook('cq')
      cookbook_file.run_action(:create)

      compile_decryptor if cookbook_file.updated_by_last_action?
    end

    def compile_decryptor
      cmd_str = "javac -cp '#{crypto_classpath}' Decrypt.java"
      cmd = Mixlib::ShellOut.new(cmd_str, :cwd => crypto_root_dir)
      cmd.run_command
      cmd.error!

      Chef::Log.debug("Compilation command: #{cmd_str}")
      Chef::Log.debug('Decryptor successfully compiled')
    rescue => e
      Chef::Application.fatal!("Compilation error: #{e}")
    end

    # Downloads master key from AEM and saves it into crypto tmp directory
    #
    # Returns key name
    def load_master_key(instance, username, password)
      http_resp = http_get(
        instance,
        '/etc/key/master',
        username,
        password
      )

      Chef::Application.fatal!(
        "Can't download master key! Response code: #{http_resp.code}"
      ) if http_resp.code != '200'

      save_key(http_resp.body)
    end

    def save_key(content)
      require 'securerandom'

      uuid = SecureRandom.uuid
      path = ::File.join(crypto_tmp_dir, uuid)

      Chef::Log.debug("Master key name: #{uuid}")
      Chef::Log.debug("Master key path: #{path}")

      begin
        ::File.write(path, content)
      rescue => e
        Chef::Application.fatal!("Can't write master key to #{path}: #{e}")
      end

      uuid
    end

    def unload_master_key(name)
      path = ::File.join(crypto_tmp_dir, name)

      Chef::Log.info("Deleting #{path}...")

      ::File.delete(path)

      Chef::Log.info('Master key file has been successfully deleted')
    rescue => e
      Chef::Log.error("Can't delete #{path} file: #{e}")
    end

    def entropy_builder
      require 'securerandom'

      Thread.new { SecureRandom.uuid() while true }
    end

    def decrypt(key, str)
      cmd_str = "java -cp '#{crypto_classpath}' Decrypt '#{key}' '#{str}'"

      Chef::Log.debug("Decrypt command: #{cmd_str}")

      # Decrypt code needs high entropy level to get things done in an
      # acceptable time frame. With this trick it takes miliseconds to finish,
      # without it execution used to take a minute or more.
      t = entropy_builder

      cmd = Mixlib::ShellOut.new(cmd_str, :cwd => crypto_root_dir)
      cmd.run_command

      Thread.kill(t)

      Chef::Log.debug("Decrypt stdout: #{cmd.stdout}")
      Chef::Log.debug("Decrypt stderr: #{cmd.stderr}")
      Chef::Log.debug("Decrypt execution time: #{cmd.execution_time}")

      cmd.error!

      # Get rid of leading/trailing whitespaces from the output
      cmd.stdout.strip
    rescue => e
      Chef::Log.debug("Decryption error: #{e}")
      case cmd.exitstatus
      when 1
        Chef::Application.fatal!("Wrong number of arguments: #{e}")
      when 2
        Chef::Application.fatal!("Error while reading master key: #{e}")
      when 3
        Chef::Log.error("Error while decrypting #{str}")
        nil
      when 4
        Chef::Application.fatal!(
          "Error while initializing cipher with master key: #{e}"
        )
      when 5
        Chef::Application.fatal!("Master key file does not exist: #{e}")
      end
    end

    def encrypt(instance, username, password, str)
      http_resp = http_post(
        instance,
        '/system/console/crypto/.json',
        username,
        password,
        'datum' => str
      )

      Chef::Application.fatal!(
        "Crypto console returned #{http_resp.code}!"
      ) if http_resp.code != '200'

      Chef::Log.debug("Crypto console response: #{http_resp.body}")

      json_to_hash(http_resp.body)['protected']
    end
  end
end
