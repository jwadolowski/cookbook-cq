#
# Cookbook Name:: cq
# Libraries:: PackageHelper
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

require 'rexml/document'

module Cq
  module PackageHelper
    include Cq::HttpHelper

    def package_list(addr, user, password)
      xml_str = http_get(
        addr,
        '/crx/packmgr/service.jsp?cmd=ls',
        user,
        password
      ).body
      REXML::Document.new(xml_str)
    rescue => e
      Chef::Log.error("Unable to parse #{xml_str} as XML: #{e}")
    end

    def package_download(src, dst, http_user, http_pass)
      auth_header = "Basic " + Base64.encode64("#{http_user}:#{http_pass}")

      remote_file = Chef::Resource::RemoteFile.new(dst, run_context)
      remote_file.source(src)
      remote_file.mode('0644')
      remote_file.backup(false)
      remote_file.headers(
        'Authorization' => auth_header
      ) if auth_header_required?(http_user, http_pass)
      remote_file.run_action(:create)
    end

    def zip_metadata(path)
    end
  end
end
