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

  # Get all instances of given factory OSGi config PID
  #
  # @param pid [String] factory PID to look for
  # @return [Array] a list of all instances of a given OSGi factory
  def factory_instaces(pid)
    regex = pid.gsub(/\./, '\.') + '\.' +
      '[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}'
    config_list.scan(/#{regex}/)
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

  # Get all POST requests that read settings given PID
  #
  # @param pid [String] PID
  # @return [Array] array of elements (request lines)
  def read_requests(pid)
    log_entries(
      pid,
      "POST\ \/system\/console\/configMgr\/#{pid}\ HTTP\/1\.1"
    )
  end

  # Get all POST requests that modify given factory config
  #
  # @param pid [String] factory PID
  # @return [Array] array of elements (request lines)
  def factory_update_requests(pid)
    log_entries(
      pid,
      'POST\ \/system\/console\/configMgr\/%5BTemporary%20PID%20replaced'\
      "%20by%20real%20PID%20upon%20save%5D\?.*factoryPid=#{pid}"\
      '.*\ HTTP\/1\.1'
    )
  end

  # Get all POST requests that modify given regular config
  #
  # @param pid [String] PID
  # @return [Array] array of elements (request lines)
  def regular_update_requests(pid)
    log_entries(
      pid,
      "POST\ \/system\/console\/configMgr\/#{pid}\?"\
      '.*apply=true.*action=ajaxConfigManager.*\ HTTP\/1\.1'
    )
  end

  # Get all requests that includes given PID
  #
  # @param pid [String] PID
  # @return [Array] array of elements (request lines)
  def all_requests(pid)
    log_entries(
      pid,
      "POST\ \/system\/console\/configMgr\/.*#{pid}.*\ HTTP\/1\.1"
    )
  end

  # Get all lines that contain a given string in AEM access.log and was
  # generated between start and stop timetamps (generated during provisioning)
  #
  # @param pid [String] OSGi configuration PID
  # @param msg [String] string to look for
  # @return [Array] array with matched lines as elements
  def log_entries(pid, msg)
    src_file = '/opt/cq/author/crx-quickstart/logs/access.log'

    start_time = DateTime.parse(File.read("/tmp/#{pid}_start_timestamp"))
    stop_time = DateTime.parse(File.read("/tmp/#{pid}_stop_timestamp"))

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

      next if regex_groups.nil? ||
        regex_groups['date'].nil? ||
        regex_groups['time'].nil?

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
