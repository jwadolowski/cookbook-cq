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
    regex = pid.gsub(/\./, '\.') + '\.'\
      '[a-z0-9]{8}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{4}-[a-z0-9]{12}'
    config_list.scan(/#{regex}/)
  end

  # Get value of a specific key for a given OSGi config PID
  #
  # @param pid [String] PID of OSGi config
  # @param key [String] name of configuration key/id
  # @return [String] value for a given key
  def config_value(pid, key)
    require 'json'

    raw_json = `/opt/scripts/CQ-Unix-Toolkit/cqcfg \
     -u admin \
     -p admin \
     -i http://localhost:4502 \
     -j #{pid}`

    out = JSON.parse(raw_json)['properties'][key]['value']
    out = JSON.parse(raw_json)['properties'][key]['values'] if out.nil?

    out
  end

  # Check whether given property is set or not
  #
  # @param pid [String] PID of OSGi config
  # @param key [String] name of configuration key/id
  # @return [Boolean] true if config is set, false otherwise
  def config_is_set(pid, key)
    require 'json'

    raw_json = `/opt/scripts/CQ-Unix-Toolkit/cqcfg \
     -u admin \
     -p admin \
     -i http://localhost:4502 \
     -j #{pid}`

    JSON.parse(raw_json)['properties'][key]['is_set']
  end
end

class CrxPackageHelper
  # Get list of all packages from AEM instance
  #
  # @return [String] a list of packages
  def package_list
    `/opt/scripts/CQ-Unix-Toolkit/cqls \
    -i http://localhost:4502 \
    -u admin \
    -p admin \
    -l -m | tr '\t' '|'`
  end

  # Checks if package is installed on a given list (instance)
  #
  # @param name [String] regex for package name
  # @param version [String] regex for package version
  # @param list [String] a list of packages
  # @return [Boolean] true if package is installed, false otherwise
  def package_installed(name, version, list)
    begin
      dt = list.scan(/^#{name}.*#{version}.*/).first.split('|')[9]

      DateTime.parse(dt)
    rescue
      return false
    end

    true
  end

  # Checks if package is uploaded on a given list (instance)
  #
  # @param name [String] regex for package name
  # @param version [String] regex for package version
  # @param list [String] a list of packages
  # @return [Boolean] true if package is uploaded, false otherwise
  def package_exists(name, version, list)
    status = list.scan(/^#{name}.*#{version}.*/).first

    status.nil? ? false : true
  end
end

RSpec.configure do |c|
  c.before :all do
    @osgi_config_helper = OSGiConfigHelper.new
    @config_list = @osgi_config_helper.config_list

    @package_helper = CrxPackageHelper.new
    @package_list = @package_helper.package_list
  end
end
