require 'serverspec'

set :backend, :exec

class OSGiConfigHelper
  # Get list of all available configurations
  #
  # @return [String] list of all OSGi config PIDs
  def config_list
    `/opt/scripts/CQ-Unix-Toolkit/cqcfgls \
     -u admin \
     -p admin \
     -i http://localhost:4502`
  end

  # Get value of a specific key for a given OSGi config PID
  #
  # @param pid [String] PID of OSGi config
  # @param key [String] name of configuration key/id
  # @return [String] value for a given key
  def config_value(pid, key)
    `/opt/scripts/CQ-Unix-Toolkit/cqcfg \
     -u admin \
     -p admin \
     -i http://localhost:4502 \
    #{pid} | grep #{key} | awk '{print $2}'`
  end

  # Get number of all occurences of a string in given AEM log file
  #
  # @param log [String] name of log
  # @param regex [String] regex to match
  # @return [Integer] number of matched lines
  def log_entries_number(log, msg)
    `grep \
    -i \
    -E "#{msg}" \
    /opt/cq/author/crx-quickstart/logs/#{log}`.lines.to_a.length
  end
end

RSpec.configure do |c|
  c.before :all do
    @osgi_config_helper = OSGiConfigHelper.new
    @config_list = @osgi_config_helper.config_list
  end
end
