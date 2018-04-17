#
# Cookbook Name:: cq
# Libraries:: OsgiStatusHelper
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

module Cq
  module OsgiStatusHelper
    include Cq::HttpHelper

    # TODO: retry on error!
    #
    # Output format
    #
    # *** System Properties:
    # awt.toolkit = sun.awt.X11.XToolkit
    # com.rsa.crypto.default.random = FIPS186PRNG
    # com.rsa.cryptoj.jce.kat.strategy = on.demand
    # file.encoding = UTF-8
    # file.encoding.pkg = sun.io
    # file.separator = /
    # java.awt.graphicsenv = sun.awt.X11GraphicsEnvironment
    # java.awt.headless = true
    def raw_system_properties(addr, user, password)
      http_get(
        addr,
        '/system/console/status-System%20Properties.txt',
        user,
        password
      ).body
    end

    # Output format
    #
    # {
    #   "awt.toolkit" => "sun.awt.X11.XToolkit",
    #   "com.rsa.crypto.default.random" => "FIPS186PRNG",
    #   "com.rsa.cryptoj.jce.kat.strategy" => "on.demand",
    #   "file.encoding" => "UTF-8",
    #   "file.encoding.pkg" => "sun.io",
    #   "file.separator" => "/",
    #   "java.awt.graphicsenv" => "sun.awt.X11GraphicsEnvironment",
    #   "java.awt.headless" => "true"
    # }
    def system_properties(addr, user, password)
      # Covert raw txt into array of key=value strings
      arr = raw_system_properties(
        addr, user, password
      ).split("\n").select { |l| l.match(/=/) }

      # Convert array into a hash
      properties = arr.map do |e|
        e.match(
          /^(?<key>[0-9a-zA-Z]+(\.[0-9a-zA-Z]+)*)\ =\ (?<value>.*)$/
        ).captures
      end.to_h

      Chef::Log.debug("System properites: #{properties}")

      properties
    end

    def system_property(addr, user, password, property)
      system_properties(addr, user, password)[property]
    end
  end
end
