#
# Cookbook:: cq
# Libraries:: CryptoHelper
#
# Copyright:: (C) 2018 Jakub Wadolowski
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
require_relative '_osgi_bundle_helper'
require_relative '_osgi_status_helper'

module Cq
  module CryptoHelper
    include Cq::HttpHelper
    include Cq::OsgiBundleHelper
    include Cq::OsgiStatusHelper

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
        ::File.join(crypto_log_dir, '*'),
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
      Chef::Log.debug("Unzip command: #{cmd_str}")

      cmd = Mixlib::ShellOut.new(cmd_str)
      cmd.run_command
      cmd.error!

      Chef::Log.debug("JAR file successfully extracted:\n #{cmd.stdout}")
    rescue => e
      Chef::Application.fatal!("Can't extract content out of JAR file: #{e}")
    end

    def jar_contents(jar)
      cmd_str = "unzip -l #{jar}"
      Chef::Log.debug("Unzip command: #{cmd_str}")

      cmd = Mixlib::ShellOut.new(cmd_str)
      cmd.run_command
      cmd.error!

      cmd.stdout
    rescue => e
      Chef::Application.fatal!("Can't list JAR file contents: #{e}")
    end

    # AEM 6.1:
    # - resources/install/0/com.adobe.granite.crypto-3.0.18-CQ610-B0004.jar
    # AEM 6.2 onwards:
    # - resources/bundles/1/com.adobe.granite.crypto-X.Y.Z.jar
    def crypto_jar_internal_path(jar)
      libs = jar_contents(jar).scan(
        %r{
          (?<=\ )resources\/.*
          (?<=\/[0-9])\/
          com\.adobe\.granite\.crypto-[0-9]+\.[0-9]+\.[0-9]+[^\.]*\.jar$
        }x
      ).flatten

      Chef::Application.fatal!(
        "Found #{libs}, but single JAR file is expected. Aborting!"
      ) if libs.length != 1

      libs.first
    end

    def crypto_jar_system_path(dir)
      ::Dir.glob("#{dir}/*").select do |f|
        ::File.file?(f) &&
          f.match(/com\.adobe\.granite\.crypto-[0-9]+\.[0-9]+\.[0-9]+[^\.]*\.jar/)
      end.first
    end

    # Source:
    # * http://stackoverflow.com/a/1096159/6802186
    # * http://stackoverflow.com/a/27123/6802186
    #
    # | Major.minor | Target  |
    # | ----------- | ------- |
    # | 45.3        | 1.1     |
    # | 46.0        | 1.2     |
    # | 47.0        | 1.3     |
    # | 48.0        | 1.4     |
    # | 49.0        | 5 (1.5) |
    # | 50.0        | 6 (1.6) |
    # | 51.0        | 7 (1.7) |
    # | 52.0        | 8 (1.8) |
    def jvm_version_mapper(major_minor)
      version_map = {
        '45.3' => '1',
        '46.0' => '2',
        '47.0' => '3',
        '48.0' => '4',
        '49.0' => '5',
        '50.0' => '6',
        '51.0' => '7',
        '52.0' => '8',
      }

      version_map[major_minor]
    end

    # Returns version of Java given file in crypto_root_dir was compiled with
    def compiled_with?(filename)
      cmd_str = "javap -cp '#{crypto_classpath}' -verbose #{filename}"
      Chef::Log.debug("javap command: #{cmd_str}")

      cmd = Mixlib::ShellOut.new(cmd_str, cwd: crypto_root_dir)
      cmd.run_command
      cmd.error!

      Chef::Log.debug("javap output: #{cmd.stdout}")
      major = cmd.stdout[/^\s+major\sversion:\s(?<version>.+)/, 'version']
      minor = cmd.stdout[/^\s+minor\sversion:\s(?<version>.+)/, 'version']

      java_version = jvm_version_mapper(major + '.' + minor)
      Chef::Log.debug("#{filename} was compiled with Java #{java_version}")

      java_version
    rescue => e
      Chef::Application.fatal!("Cannot disassemble #{filename} file: #{e}")
    end

    def jvm_version_changed?(filename)
      node['java']['jdk_version'] != compiled_with?(filename)
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

      # Recompile Decrypt.java if needed
      compile_decryptor if !File.exist?(decryptor_path + '.class') ||
                           jvm_version_changed?('Decrypt')
    end

    def crypto_dir_structure
      dirs = [
        crypto_aem_dir,
        crypto_log_dir,
        crypto_tmp_dir,
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
        Chef::Application.fatal!(
          'Crypto tmp directory should contain only one CQ quickstart JAR '\
          "file. Found: #{tmp_files}. That's either a bug in CQ cookbook or "\
          'something is wrong with your primary JAR file'
        ) if tmp_files.length != 1
        standalone_jar = tmp_files.first

        # Extract com.adobe.granite.crypto-x.y.z.jar file from the standalone
        # JAR file
        extract_jar(
          standalone_jar,
          crypto_jar_internal_path(standalone_jar),
          crypto_aem_dir
        )

        # Remove standalone JAR, as it is no longer needed
        ::File.delete(standalone_jar)

        # Extract libs out of com.adobe.granite.crypto-x.y.z.jar file
        extract_jar(
          crypto_jar_system_path(crypto_aem_dir),
          'META-INF/lib/*',
          crypto_aem_dir
        )
      end

      Chef::Log.debug('All AEM crypto libraries are in place')
    end

    def download_log_libs
      node['cq']['crypto']['log_libs']['data'].each do |path, checksum|
        url = node['cq']['crypto']['log_libs']['server'] + path
        filename = uri_basename(url)
        path = ::File.join(crypto_log_dir, filename)

        remote_file = Chef::Resource::RemoteFile.new(path, run_context)
        remote_file.source(url)
        remote_file.mode('0644')
        remote_file.use_conditional_get(false)
        remote_file.checksum(checksum)
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
      Chef::Log.debug("Compilation command: #{cmd_str}")

      cmd = Mixlib::ShellOut.new(cmd_str, cwd: crypto_root_dir)
      cmd.run_command
      cmd.error!

      Chef::Log.debug('Decryptor successfully compiled')
    rescue => e
      Chef::Application.fatal!("Compilation error: #{e}")
    end

    # TODO: move to misc helper module, as the same has been defined in
    # package helper
    def sleep_time(attempt)
      1 + (2**attempt) + rand(2**attempt)
    end

    # Download master key file directly from the instance (AEM < 6.3)
    def download_master_key(instance, username, password)
      max_attempts ||= 3
      attempt ||= 1

      resp = http_get(
        instance,
        '/etc/key/master',
        username,
        password
      )

      unless resp.is_a?(Net::HTTPResponse)
        raise(Net::HTTPUnknownResponse, 'Unknown HTTP response')
      end

      # Return raw HTTP response, so status code can be evaluated
      resp
    rescue => e
      if (attempt += 1) <= max_attempts
        t = sleep_time(attempt)
        Chef::Log.error(
          "[#{attempt}/#{max_attempts}] Unable to download master key, "\
          "retrying in #{t}s (reason: #{e})"
        )
        sleep(t)
        retry
      end
    end

    # Use com.adobe.granite.crypto.file information to retrive the key
    #
    # Compatible with AEM 6.3+
    #
    # http://www.nateyolles.com/blog/2017/05/sharing-crypto-keys-in-aem-63
    def find_master_key(instance, username, password)
      bundle_name = 'com.adobe.granite.crypto.file'
      bundle_info = bundle_info(instance, username, password, bundle_name)
      bundle_id = bundle_info['id']

      Chef::Log.debug("com.adobe.granite.crypto.file bundle ID: #{bundle_id}")

      root_dir = system_property(
        instance,
        username,
        password,
        'user.dir'
      )

      key_path = ::File.join(
        root_dir,
        "/crx-quickstart/launchpad/felix/bundle#{bundle_id}/data/master"
      )

      Chef::Log.debug("Master key system path: #{key_path}")

      if ::File.file?(key_path)
        ::File.read(key_path)
      else
        Chef::Application.fatal!("#{key_path} doesn't exist!")
      end
    end

    # Retrieves master key from AEM and saves it into crypto tmp directory
    def load_master_key(instance, username, password)
      key_resp = download_master_key(instance, username, password)
      key_content =
        if key_resp.code == '200'
          key_resp.body
        else
          find_master_key(instance, username, password)
        end

      save_key(key_content)
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
      spawn('rngd -r /dev/urandom -o /dev/random -f')
    end

    def decrypt(key, str)
      cmd_str = "java -cp '#{crypto_classpath}' Decrypt '#{key}' '#{str}'"
      Chef::Log.debug("Decrypt command: #{cmd_str}")

      # Decrypt code needs high entropy level to get things done in an
      # acceptable time frame. With this trick it takes miliseconds to finish,
      # without it execution used to take a minute or more.
      p = entropy_builder
      Chef::Log.debug("Entropy builder PID: #{p}")

      cmd = Mixlib::ShellOut.new(cmd_str, cwd: crypto_root_dir)
      cmd.run_command

      Process.kill('INT', p)

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
