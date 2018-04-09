#
# Cookbook Name:: cq
# Libraries:: PackageHelper
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

require 'rexml/document'

module Cq
  module PackageHelper
    include Cq::HttpHelper

    def xmlify(str)
      REXML::Document.new(str)
    rescue => e
      Chef::Application.fatal!("Can't serialize #{str} to XML: #{e}")
    end

    def sleep_time(attempt)
      1 + (2**attempt) + rand(2**attempt)
    end

    def raw_package_list(addr, user, password)
      max_attempts ||= 3
      attempt ||= 1

      resp = http_get(
        addr, '/crx/packmgr/service.jsp', user, password, 'cmd' => 'ls'
      )

      unless resp.is_a?(Net::HTTPResponse)
        raise(Net::HTTPUnknownResponse, 'Unknown HTTP response')
      end

      unless resp.code == '200'
        raise(Net::HTTPBadResponse, "#{resp.code} error")
      end

      Chef::Log.debug("Package list response code: #{resp.code}")
      Chef::Log.debug("Package list response body: #{resp.body}")
    rescue => e
      if (attempt += 1) <= max_attempts
        t = sleep_time(attempt)
        Chef::Log.error(
          "[#{attempt}/#{max_attempts}] Retrying in #{t}s (reason: #{e})"
        )
        sleep(t)
        retry
      else
        Chef::Application.fatal!(
          "Unable to fetch package list after #{max_attempts} attempts"
        )
      end
    else
      resp.body
    end

    def package_list(addr, user, password)
      packages = REXML::XPath.first(
        xmlify(raw_package_list(addr, user, password)),
        '//packages'
      )

      if packages.nil?
        raise(
          REXML::ParseException,
          'Package Manager response does NOT contain <packages> element!'
        )
      end
    rescue => e
      Chef::Application.fatal!(e.message)
    else
      packages
    end

    def package_download(src, dst, http_user, http_pass)
      auth_header = 'Basic ' + Base64.encode64("#{http_user}:#{http_pass}")

      remote_file = Chef::Resource::RemoteFile.new(dst, run_context)
      remote_file.source(src)
      remote_file.mode('0644')
      remote_file.backup(false)
      if auth_header_required?(http_user, http_pass)
        remote_file.headers('Authorization' => auth_header)
      end
      remote_file.run_action(:create)
    end

    def package_upload(instance, user, pass, path)
      req_path = '/crx/packmgr/service/.json/'
      query_params = { 'cmd' => 'upload' }
      payload = file_upload_payload(
        'package',
        path,
        'application/zip'
      )

      http_resp = http_multipart_post(
        instance,
        req_path,
        user,
        pass,
        payload,
        query_params
      )

      response_validator(http_resp.body)
    end

    def package_install(instance, user, pass, pkg_path, recursive)
      req_path = '/crx/packmgr/service/.json' + pkg_path
      query_params = { 'cmd' => 'install', 'recursive' => recursive }

      http_resp = http_post(
        instance,
        req_path,
        user,
        pass,
        {},
        query_params
      )

      response_validator(http_resp.body)
    end

    def package_uninstall(instance, user, pass, pkg_path)
      req_path = '/crx/packmgr/service/.json' + pkg_path
      query_params = { 'cmd' => 'uninstall' }

      http_resp = http_post(
        instance,
        req_path,
        user,
        pass,
        {},
        query_params
      )

      response_validator(http_resp.body)
    end

    def package_delete(instance, user, pass, pkg_path)
      req_path = '/crx/packmgr/service/.json' + pkg_path
      query_params = { 'cmd' => 'delete' }

      http_resp = http_post(
        instance,
        req_path,
        user,
        pass,
        {},
        query_params
      )

      response_validator(http_resp.body)
    end

    def response_validator(str)
      response = json_to_hash(str)

      if response['success']
        Chef::Log.debug("CRX Package Manager response: #{response}")
      else
        Chef::Application.fatal!(
          "Not successful package operation: #{response}"
        )
      end
    end

    def crx_path(group, name)
      pkg_path = '/etc/packages'
      pkg_path += "/#{group}" unless group.to_s.empty?
      pkg_path += "/#{name}"
      pkg_path
    end

    def properties_xml_file(path)
      cmd_str = "unzip -p #{path} META-INF/vault/properties.xml"
      cmd = Mixlib::ShellOut.new(cmd_str)
      cmd.run_command

      begin
        cmd.error!
        xmlify(cmd.stdout)
      rescue => e
        Chef::Application.fatal!(
          "Can't extract properties.xml from #{path} file: #{e}"
        )
      end
    end

    def xml_property(xml, name)
      element = REXML::XPath.first(xml, "//entry[@key='#{name}']")
      element.nil? ? element : element.text
    end

    def crx_property(xml, name)
      begin
        element = xml.elements[name]
      rescue => e
        Chef::Application.fatal!(
          "Can't extract #{name} from package object: #{e}"
        )
      end

      if element.nil?
        element
      else
        element.text
      end
    end
  end
end
