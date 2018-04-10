#
# Cookbook Name:: cq
# Libraries:: helpers
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

# Get filename from given URI
# -----------------------------------------------------------------------------
def cq_jarfile(uri)
  require 'pathname'
  require 'uri'
  Pathname.new(URI.parse(uri).path).basename.to_s
end

# Get CQ instance home for given mode (author/publish)
# -----------------------------------------------------------------------------
def cq_instance_home(home_dir, mode)
  "#{home_dir}/#{mode}"
end

# Get CQ conf dir
# -----------------------------------------------------------------------------
def cq_instance_conf_dir(home_dir, mode)
  "#{cq_instance_home(home_dir, mode)}/crx-quickstart/conf"
end

# Get different form of given CQ version
# -----------------------------------------------------------------------------
def cq_version(type)
  case type
  when 'short'
    # Example: 5.6.1 => 5.6
    node['cq']['version'].to_s.delete('^0-9')[0, 3]
  when 'short_squeezed'
    # Example: 5.6.1 => 56
    node['cq']['version'].to_s.delete('^0-9')[0, 2]
  end
end

# Create deamon name for given CQ instance type
# -----------------------------------------------------------------------------
def cq_daemon_name(mode)
  "cq#{cq_version('short_squeezed')}-#{mode}"
end
