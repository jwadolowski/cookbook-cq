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
     -m #{pid} | grep #{key} | cut -d$'\t' -f2`
  end

  # Get all lines that contain a given string in AEM access.log and was
  # generated between start and stop timetamps (generated during provisioning)
  #
  # @param msg [String] string (config name) to look for
  # @return [Array] array with matched lines as elements
  def log_entries(msg)
    src_file = '/opt/cq/author/crx-quickstart/logs/access.log'

    start_time = DateTime.parse(File.read("/tmp/#{msg}_start_timestamp"))
    stop_time = DateTime.parse(File.read("/tmp/#{msg}_stop_timestamp"))

    line_regex = %r{
      ^[0-9.]+
      \ [-\w]+
      \ \w+
      \ (?<date>[0-9]{2}\/\w+\/[0-9]{4})
      :(?<time>[0-9]{2}:[0-9]{2}:[0-9]{2})
    }x

    array = []

    File.open(src_file).each do |line|
      regex_groups = line.match(line_regex)

      next if regex_groups['date'].nil? || regex_groups['time'].nil?

      line_time = DateTime.parse(
        regex_groups['date'] + ' ' + regex_groups['time']
      )

      array.push(line) if line.match(/#{msg}/) &&
        line_time >= start_time &&
        line_time <= stop_time
    end

    array
  end
end

RSpec.configure do |c|
  c.before :all do
    @osgi_config_helper = OSGiConfigHelper.new
    @config_list = @osgi_config_helper.config_list
  end
end
