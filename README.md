# CQ/AEM Chef cookbook

This cookbook deploys and configures Adobe Experience Manager (AEM), formerly known as CQ.

FYI, it is not called `aem-coobkook`, because when I started development there was no AEM yet (it was known as CQ at
that time). Nowadays the `aem` name seems to be taken anyways, so I no longer have a choice.

# Table of contents

- [Supported platforms](#supported-platforms)
  - [Operating systems](#operating-systems)
  - [Chef versions](#chef-versions)
  - [AEM/CQ versions](#aemcq-versions)
- [Getting started](#getting-started)
- [Attributes](#attributes)
  - [default.rb](#defaultrb)
  - [author.rb](#authorrb)
  - [publish.rb](#publishrb)
- [Recipes](#recipes)
  - [default.rb](#defaultrb-1)
  - [commons.rb](#commonsrb)
  - [author.rb](#authorrb-1)
  - [publish.rb](#publishrb-1)
- [Custom resources](#custom-resources)
  - [cq_package](#cq_package)
    - [Actions](#actions)
    - [Properties](#properties)
    - [Usage](#usage)
  - [cq_osgi_config](#cq_osgi_config)
    - [Actions](#actions-1)
    - [Properties](#properties-1)
    - [Compatibility matrix](#compatibility-matrix)
    - [Usage](#usage-1)
      - [Regular OSGi configs](#regular-osgi-configs)
      - [Factory OSGi configs](#factory-osgi-configs)
  - [cq_osgi_bundle](#cq_osgi_bundle)
    - [Actions](#actions-2)
    - [Properties](#properties-2)
    - [Usage](#usage-2)
  - [cq_osgi_component](#cq_osgi_component)
    - [Actions](#actions-3)
    - [Properties](#properties-3)
    - [Usage](#usage-3)
  - [cq_user](#cq_user)
    - [Actions](#actions-4)
    - [Properties](#properties-4)
    - [Compatibility matrix](#compatibility-matrix-1)
    - [Usage](#usage-4)
  - [cq_jcr](#cq_jcr)
    - [Actions](#actions-5)
    - [Properties](#properties-5)
    - [Usage](#usage-5)
  - [cq_start_guard](#cq_start_guard)
    - [Actions](#actions-6)
    - [Properties](#properties-6)
    - [Usage](#usage-6)
  - [cq_clientlib_cache](#cq_clientlib_cache)
    - [Actions](#actions-7)
    - [Properties](#properties-7)
    - [Usage](#usage-7)
- [Testing](#testing)
- [Author](#author)

# Supported platforms

## Operating systems

- CentOS/RHEL 7.x
- CentOS/RHEL 8.x
- Amazon Linux

## Chef versions

- Chef 16.x

## AEM/CQ versions

- AEM 6.1.0
- AEM 6.2.0
- AEM 6.3.0
- AEM 6.4.0
- AEM 6.5.0

# Getting started

TBD

# Attributes

For default values please refer to appropriate files.

## default.rb

To set Java related attributes please refer to [java cookbook](https://github.com/agileorbit-cookbooks/java). By default
it installs Oracle's JDK7.

- ( **String** ) `node['cq']['user']` - System user for CQ/AEM service
- ( **String** ) `node['cq']['user_uid']` - UID of CQ/AEM user
- ( **String** ) `node['cq']['user_comment']` - Comment/description of CQ/AEM user
- ( **String** ) `node['cq']['user_shell']` - Default shell of CQ/AEM user
- ( **String** ) `node['cq']['group']` - System group for CQ/AEM
- ( **String** ) `node['cq']['group_gid']` - GID of CQ/AEM group
- ( **String** ) `node['cq']['limits']['file_descriptors']` - Max number of open file descriptor for CQ/AEM user
- ( **String** ) `node['cq']['base_dir']` - Base directory for CQ/AEM instance(s)
- ( **String** ) `node['cq']['home_dir']` - Home directory under which CQ/AEM instances are deployed
- ( **String** ) `node['cq']['version']` - CQ/AEM version
- ( **String** ) `node['cq']['custom_tmp_dir']` - Custom directory that JVM uses for temporary files
- ( **String** ) `node['cq']['jar']['url']` - URL from which CQ/AEM JAR file is downloaded
- ( **String** ) `node['cq']['jar']['checksum']` - SHA256 checksum of CQ/AEM JAR file
- ( **String** ) `node['cq']['license']['url']` - URL from which CQ/AEM license is downloaded
- ( **String** ) `node['cq']['license']['checksum']` - SHA256 checksum of CQ/AEM license file
- ( **Integer** ) `node['cq']['service']['start_timeout']` - Max number of seconds to wait until CQ/AEM instance is
  fully operational after service start
- ( **Integer** ) `node['cq']['service']['kill_delay']` - Max number of seconds for graceful instance stop before
    `KILL`
  signal is sent to the process
- ( **Integer** ) `node['cq']['service']['restart_sleep']` - Number of seconds to wait between service stop and start
- ( **String** ) `node['cq']['init_template_cookbook']` - Cookbook which is a source for init script template
- ( **String** ) `node['cq']['conf_template_cookbook']` - Cookbook which is a source for conf file template

## author.rb

All attributes in this file refer to CQ/AEM author instance (`node['cq']['author']` namespace).

- ( **String** ) `node['cq']['author']['run_mode']` - Instance run mode
- ( **String** ) `node['cq']['author']['port']` - Main port of CQ/AEM instance
- ( **String** ) `node['cq']['author']['jmx_ip']` - Value of `-Djava.rmi.server.hostname` JVM parameter. Requires
  reference to `${CQ_JMX_IP}` shell variable in `node['cq']['author']['jvm']['jmx_opts']` attribute to be effective
- ( **String** ) `node['cq']['author']['jmx_port']` - Value of `-Dcom.sun.management.jmxremote.port` and
  `-Dcom.sun.management.jmxremote.rmi.port` JVM parameters. Requires reference to `${CQ_JMX_PORT}` shell variable in
  `node['cq']['author']['jvm']['jmx_opts']` attribute to be effective
- ( **String** ) `node['cq']['author']['debug_ip']` - IP to listen on with debug interface. Requires reference to
  `${CQ_DEBUG_IP}` shell variable in `node['cq']['author']['jvm']['debug_opts']` attribute to be effective
- ( **String** ) `node['cq']['author']['debug_port']` - Port of JVM debug interface. Requires reference to
  `${CQ_DEBUG_PORT}` shell variable in `node['cq']['author']['jvm']['debug_opts']` attribute to be effective
- ( **String** ) `node['cq']['author']['credentials']['login']` - User that's used to perform actions on your CQ/AEM
  instance. The most typical scenarios require admin
- ( **String** ) `node['cq']['author']['credentials']['password']` - Password of user specified in
  `node['cq']['author']['credentials']['login']`
- ( **String** ) `node['cq']['author']['jvm']['min_heap']` - `-Xms` JVM parameter (in megabytes)
- ( **String** ) `node['cq']['author']['jvm']['max_heap']` - `-Xmx` JVM parameter (in megabytes)
- ( **String** ) `node['cq']['author']['jvm']['max_perm_size']` - `-XX:MaxPermSize` JVM parameter (in megabytes)
- ( **String** ) `node['cq']['author']['jvm']['code_cache_size']` - `-XX:ReservedCodeCacheSize` JVM parameter (in
  megabytes)
- ( **String** ) `node['cq']['author']['jvm']['general_opts']` - Generic JVM parameters
- ( **String** ) `node['cq']['author']['jvm']['code_cache_opts']` - JVM parameters related to its code cache
- ( **String** ) `node['cq']['author']['jvm']['gc_opts']` - JVM parameters related to garbage collection
- ( **String** ) `node['cq']['author']['jvm']['jmx_opts']` - JVM parameters related to JMX settings
- ( **String** ) `node['cq']['author']['jvm']['debug_opts']` - JVM parameters related to debug interface
- ( **String** ) `node['cq']['author']['jvm']['crx_opts']` - CRX related JVM parameters
- ( **String** ) `node['cq']['author']['jvm']['extra_opts']` - All other JVM parameters
- ( **String** ) `node['cq']['author']['healthcheck']['resource']` - Resource that's queried during instance start to
  determine whether CQ/AEM is fully operational
- ( **String** ) `node['cq']['author']['healthcheck']['response_code']` - Expected HTTP status code of healthcheck
  resource
- ( **String** ) `node['cq']['author']['healthcheck']['response_body']` - Expected string in HTTP healthcheck response

## publish.rb

All attributes in this file refer to CQ/AEM publish instance (`node['cq']['publish']` namespace).

- ( **String** ) `node['cq']['publish']['run_mode']` - Instance run mode
- ( **String** ) `node['cq']['publish']['port']` - Main port of CQ/AEM instance
- ( **String** ) `node['cq']['publish']['jmx_ip']` - Value of `-Djava.rmi.server.hostname` JVM parameter.Requires
  reference to `${CQ_JMX_IP}` shell variable in `node['cq']['publish']['jvm']['jmx_opts']` attribute to be effective
- ( **String** ) `node['cq']['publish']['jmx_port']` - Value of `-Dcom.sun.management.jmxremote.port` and
  `-Dcom.sun.management.jmxremote.rmi.port` JVM parameters. Requires reference to `${CQ_JMX_PORT}` shell variable in
  `node['cq']['publish']['jvm']['jmx_opts']` attribute to be effective
- ( **String** ) `node['cq']['publish']['debug_ip']` - IP to listen on with debug interface. Requires reference to
  `${CQ_DEBUG_IP}` shell variable in `node['cq']['publish']['jvm']['debug_opts']` attribute to be effective
- ( **String** ) `node['cq']['publish']['debug_port']` - Port of JVM debug interface. Requires reference to
  `${CQ_DEBUG_PORT}` shell variable in `node['cq']['publish']['jvm']['debug_opts']` attribute to be effective
- ( **String** ) `node['cq']['publish']['credentials']['login']` - User that's used to perform actions on your CQ/AEM
  instance. The most typical scenarios require admin
- ( **String** ) `node['cq']['publish']['credentials']['password']` - Password of user specified in
  `node['cq']['publish']['credentials']['login']`
- ( **String** ) `node['cq']['publish']['jvm']['min_heap']` - `-Xms` JVM parameter (in megabytes)
- ( **String** ) `node['cq']['publish']['jvm']['max_heap']` - `-Xmx` JVM parameter (in megabytes)
- ( **String** ) `node['cq']['publish']['jvm']['max_perm_size']` - `-XX:MaxPermSize` JVM parameter (in megabytes)
- ( **String** ) `node['cq']['publish']['jvm']['code_cache_size']` - `-XX:ReservedCodeCacheSize` JVM parameter (in
  megabytes)
- ( **String** ) `node['cq']['publish']['jvm']['general_opts']` - Generic JVM parameters
- ( **String** ) `node['cq']['publish']['jvm']['code_cache_opts']` - JVM parameters related to its code cache
- ( **String** ) `node['cq']['publish']['jvm']['gc_opts']` - JVM parameters related to garbage collection
- ( **String** ) `node['cq']['publish']['jvm']['jmx_opts']` - JVM parameters related to JMX settings
- ( **String** ) `node['cq']['publish']['jvm']['debug_opts']` - JVM parameters related to debug interface
- ( **String** ) `node['cq']['publish']['jvm']['crx_opts']` - CRX related JVM parameters
- ( **String** ) `node['cq']['publish']['jvm']['extra_opts']` - All other JVM parameters
- ( **String** ) `node['cq']['publish']['healthcheck']['resource']` - Resource that's queried during instance start to
  determine whether CQ/AEM is fully operational
- ( **String** ) `node['cq']['publish']['healthcheck']['response_code']` - Expected HTTP status code of healthcheck
  resource
- ( **String** ) `node['cq']['publish']['healthcheck']['response_body']` - Expected string in HTTP healthcheck response

# Recipes

## default.rb

Installs core dependencies (Ruby gems and OS packages).

## commons.rb

Takes care of common elements of every CQ/AEM deployment, including:

- system user and its configuration
- required directory structure
- Java installation
- CQ Unix Toolkit installation

## author.rb

Installs CQ/AEM author instance.

## publish.rb

Installs CQ/AEM publish instance.

# Custom resources

All CQ/AEM related resource are idempotent, so action won't be taken if not required.

Whenever you need to deploy 2 or more CQ/AEM instances on a single server please make sure you named all your custom
resources differently, as you may get unexpected results otherwise (i.e. when CQ/AEM restart is required afterwards).
Please find `cq_package` example below:

**Bad**:

```ruby
cq_package 'package1' do
  instance "http://localhost:#{node['cq']['author']['port']}"

  action :deploy
end

cq_package 'package1' do
  instance "http://localhost:#{node['cq']['publish']['port']}"

  action :deploy
end
```

**Good**:

```ruby
cq_package 'Author: package1' do
  instance "http://localhost:#{node['cq']['author']['port']}"

  action :deploy
end

cq_package 'Publish: package1' do
  instance "http://localhost:#{node['cq']['publish']['port']}"

  action :deploy
end
```

## cq_package

Allows for CRX package manipulation using CRX Package Manager API.

Key features:

- package specific details (name, group, version) are always extracted from ZIP file (`/META-INF/vault/properties.xml`),
  so you don't have to define that anywhere else. All you need is an URL to your package
- `cq_package` identifies packages by name/group/version properties
- packages are automatically downloaded from remote (`http://`, `https://`) or local (`file://`) sources. If HTTP(S)
  source requires basic auth please use `http_user` and `http_pass`
- by default all packages are downloaded to Chef's cache (`/var/chef/cache`)
- installation process is considered finished only when both "foreground" (Package Manager) and "background" (OSGi
  bundle/component restarts) ones are over - no more 'wait until you see X in `error.log`'

### Actions

If you'd like to upload and install a package, in most cases please use `deploy` action instead of combined `upload` and
`install`. Detailed explanation can be found below.

- `upload` - uploads package to given CQ instance
- `install` - installs already uploaded package
- `deploy` - uploads and installs given package as a single action. This action is quicker than separate `upload` +
  `install` as less healthchecks have to be executed
- `uninstall` - uninstalls given CQ package
- `delete` - deletes given CQ package

### Properties

- ( **String** ) `name` - Package name. Can be anything as long as it means something to you. Actual package name is
  extracted from provided ZIP file. Whenever you use notifies on your package resource and more than a single action as
  defined (i.e. `action [:upload, :install]`), two notifications will be triggered (after `:upload` and `:install`
  respectively)
- ( **String** ) `username` - Instance username
- ( **String** ) `password` - Instance password
- ( **String** ) `instance` - Instance URL
- ( **String** ) `source` - URL to ZIP package. Accepted protocols: `file://`, `http://`, `https://`
- ( **String** ) `http_user` - HTTP basic auth user. Use whenever source requires such authentication
- ( **String** ) `http_pass` - HTTP basic auth password. Use whenever source requires such authentication
- ( **Boolean** ) `recursive_install` - Whether to use recursive flag when installing packages (required for service
  packs and some hotfixes). Applies only to install and deploy actions
- ( **Boolean** ) `rescue_mode` - Some packages may cause shutdown of the entire OSGi because of dependency (i.e. cycle)
  or bundle priority issues. In such case after package installation java process is still running, however the instance
  is not responding over HTTP. After CQ/AEM restart everything works perfectly fine again. This flag allows Chef to
  continue processing if it is not able to get OSGi bundles state `error_state_barrier` times in a row. In most (if not
  all) cases it should be combined with restart notification (please see examples below). It is highly discouraged to
  use this property, as 99% of CRX packages shouldn't require such configuration. Unfortunately that 1% does. This is
  rather a safety switch than a common pattern that should be used in every single case. Applies only to install and
  deploy actions.
- ( **String** ) `checksum` - ZIP file checksum (passed through to `remote_file` resource that is used under the hood by
  `cq_package` provider)
- ( **Integer** ) `same_state_barrier` - How many times in a row the same OSGi state should occur after package
  (un)installation to consider this process successful. Default is 6
- ( **Integer** ) `error_state_barrier` - How many times in a row the OSGi console was unavailable after package
  (un)installation. Useful only when combined with `rescue_mode`. By default set to 6
- ( **Integer** ) `max_attempts` - Number of attempts while waiting for stable OSGi state after package
  (un)installation. Set to 30 by default
- ( **Integer** ) `sleep_time` - Sleep time between OSGi status checks (in seconds) after package (un)installation. Set
  to 10 by default

### Usage

```ruby
cq_package 'Slice 4.2.1' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source 'https://oss.sonatype.org/content/groups/public/com/cognifide/slice'\
    '/slice-assembly/4.2.1/slice-assembly-4.2.1-cq.zip'

  action :upload
end
```

First `cq_package` resource will download Slice package from provided URL and upload it to defined AEM Author instance.

```ruby
cq_package 'Upgrade to Oak 1.0.13' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source 'https://artifacts.example.com/aem/6.0.0/hotfixes'\
    '/cq-6.0.0-hotfix-6316-1.1.zip'
  http_user 'john'
  http_pass 'passw0rd'

  action :upload
end
```

Second resource does the same as the first one, but for Oak 1.0.13 hotfix. The only difference is that provided URL
requires basic auth, hence the `http_user` and `http_pass` properties.

```ruby
cq_package 'ACS AEM Commons 1.10.2' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source 'https://github.com/Adobe-Consulting-Services/acs-aem-commons'\
    '/releases/download/acs-aem-commons-1.10.2'\
    '/acs-aem-commons-content-1.10.2.zip'

  action [:upload, :install]
end
```

Third package shows how to combine multiple actions in a single `cq_package` resource usage.

```ruby
cq_package 'AEM6 hotfix 6316' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source node['cq']['packages']['aem6']['hf6316']
  recursive_install true

  action :deploy

  notifies :restart, 'service[cq60-author]', :immediately
end
```

4th `cq_package` presents how to use `deploy` action that combines both `upload` and `install` in a single execution.
This is preferred way of doing package deployment, in particular for those that require AEM service restart as soon as
installation is completed. `recursive_install` was also used here, which is required for majority of hotfixes and every
service pack.

```ruby
cq_package 'Geometrixx All' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source "http://localhost:#{node['cq']['author']['port']}/etc/packages"\
    '/day/cq60/product/cq-geometrixx-all-pkg-5.7.476.zip'
  http_user node['cq']['author']['credentials']['login']
  http_pass node['cq']['author']['credentials']['password']

  action :uninstall
end
```

Next example describes usage of `uninstall` action. In this particular case operation was executed against Geometrixx
package.

```ruby
cq_package 'Not really well-thought-out package' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source node['cq']['packages']['myapp']
  http_user node['cq']['author']['credentials']['login']
  http_pass node['cq']['author']['credentials']['password']
  rescue_mode true

  action :deploy

  notifies :restart, 'service[cq60-author]', :immediately
end
```

6th `cq_package` presents usage of `rescue_mode` property. Imagine that this package provides new OSGi bundles and right
after its installation some serious issue occurs (i.e. unresolvable OSGi dependency, conflict or cycle). As a result of
this event all bundles will be turned off and effectively instance will stop responding or start serving 404s for all
resources (including `/system/console`). The java process though will still be running. The only solution to that
problem is AEM restart, after which all work perfectly fine again. Without `rescue_mode` property `cq_package` provider
will keep checking OSGi bundles to detect their stable state, but none of these attempts will end successfully, as
nothing is reachable over HTTP. Eventually Chef run will be aborted. If `rescue_mode` was activated (set to `true`) then
after `error_state_barrier` unsuccessful attempts an error will be printed and the processing will be continued (restart
of `cq60-author` service in this case).

```ruby
cq_package 'Author: Service Pack 2 (upload)' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source node['cq']['packages']['aem6']['sp2']

  action :upload
end

cq_package 'Author: Service Pack 2 (install)' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source node['cq']['packages']['aem6']['sp2']
  recursive_install true
  rescue_mode true
  same_state_barrier 12
  error_state_barrier 12
  max_attempts 36

  action :install

  notifies :restart, 'service[cq60-author]', :immediately
end
```

7th & 8th `cq_package` resources explain how to deal with AEM instance restarts after package installation and tune post
installation OSGi stability checks.

Moreover it explains how to use combination of `upload` and `install` instead of `deploy`. Such procedure might be
required sometimes, i.e. when some extra steps have to be done after package upload, but before its installation.

Please notice that both resources were named differently on purpose to avoid resource merge and 2 restarts. If you'd
use:

```ruby
cq_package 'Author: Service Pack 2' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source node['cq']['packages']['aem6']['sp2']
  recursive_install true

  action [:upload, :install]

  notifies :restart, 'service[cq60-author]', :immediately
end
```

or

```ruby
cq_package 'Author: Service Pack 2' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source node['cq']['packages']['aem6']['sp2']

  action :upload
end

cq_package 'Author: Service Pack 2' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source node['cq']['packages']['aem6']['sp2']
  recursive_install true

  action :install

  notifies :restart, 'service[cq60-author]', :immediately
end
```

two restarts will be triggered.

In the first case during compile phase Chef will generate 2 resources with the same name, but different actions.

In second example restart still will be triggered after upload, even if it's not explicitly defined during 1st usage
(upload action). The reason is quite simple - both resources are named the same (`Author: Service Pack 2`) and Chef will
treat this as a single resource on resource collection. It means that notify parameter will be silently merged to the
resource with upload action during compile phase.

## cq_osgi_config

Provides an interface for CRUD operations in OSGi configs.

### Actions

For regular (non-factory, single instance) configs:

- `create` - updates already existing configuration
- `delete` - restores default settings of given OSGi config

For factory configs:

- `create` - creates a new factory instance if none of existing ones match to defined state
- `delete` - deletes factory config instance if there's one that matches to defined state

### Properties

- ( **String** ) `pid` - Config name (PID). Relevant to regular configs only
- ( **String** ) `username` - Instance username
- ( **String** ) `password` - Instance password
- ( **String** ) `instance` - Instance URL
- ( **String** ) `factory_pid` - Factory PID
- ( **Hash** ) `properties` - Key-value pairs that represent OSGi config properties
- ( **Boolean** ) `append` - If set to `true` arrays will be merged. Use if you'd like to specify just a subset of array
  elements. `false` by default. Has no impact on other property types (String, Integer, etc)
- ( **Boolean** ) `apply_all` - If `true` all properties defined in a `cq_osgi_config` resource will be used when
  applying OSGi configuration (despite of the fact just a subset differs). Example: 5 properties were defined as
  properties, 3 of them require update, but all of them will be set. `false` by default
- ( **Boolean** ) `include_missing` - Properties that were NOT defined by user, but exist in OSGi will be included as a
  part of an update if this property is set to `true` for regular OSGi configs. For factory configs it behaves almost
  the same. If new instance needs to be created then defaults defined in factory PID will be used. In case of existing
  instance update, all missing properties will be based on properties defined in that instance. This is recommended
  property when you'd like to edit pre-existing factory or regular configs. `true` by default
- ( **Array** ) `unique_fields` - Property names/keys that define uniqueness of given config. Applicable to factory
  configs only. By default, all available property keys will be used (defined by factory config on AEM instance). User
  doesn't need to define that at all, unless you want to cherry pick particular config. It's generally recommended to
  specify this for every factory OSGi config. Example: log.name key needs to stay unique for your config
- ( **Integer** ) `count` - Number of duplicated instances of given OSGi configuration. 1 by default. Applicable to
  factory configs only. Useful when duplicated instances are allowed, i.e. each instance specify some sort of a worker
  and every single one of them has exactly the same set of properties
- ( **Boolean** ) `enforce_count` - Reduces number of duplicated configs if more than count has been found. Applicable
  to factory configs only. `false` by default
- ( **Boolean** ) `force` - If `true`, defined OSGi config is deleted/updated regardless of current settings. Applies to
  regular OSGi configs only. This violates idempotence, so please use `only_if` or `not_if` blocks to prevent constant
  execution
- ( **Boolean** ) `rescue_mode` - Some config operations may cause shutdown of the entire OSGi because of dependency
  (i.e. cycle) or bundle/component priority issues. In such case after config update java process is still running,
  however the instance is not responding over HTTP. After CQ/AEM restart everything works perfectly fine again. This
  flag allows Chef to continue processing if it is not able to get OSGi component state `error_state_barrier` times in a
  row. In most (if not all) cases it should be combined with AEM restart notification. It is highly discouraged to use
  this property, as 99% of OSGi configs shouldn't require such configuration. Unfortunately that 1% does. This is rather
  a safety switch than a common pattern that should be used in every single case.
- ( **Integer** ) `same_state_barrier` - How many times in a row the same OSGi component state should occur after
  configuration update to consider this process successful. 3 by default
- ( **Integer** ) `error_state_barrier` - How many times in a row the OSGi console was unavailable after OSGi config
  update. Useful only when combined with `rescue_mode`. 3 by default
- ( **Integer** ) `max_attempts` - Number of attempts while waiting for stable OSGi state after OSGi config update. 60
  by default
- ( **Integer** ) `sleep_time` - Sleep time between OSGi component status checks (in seconds) after config update. 2 by
  default

### Compatibility matrix

| Property          | Regular OSGi config | Factory OSGi config |
| ----------------- | ------------------- | ------------------- |
| `pid`             | :white_check_mark:  | :white_check_mark:  |
| `username`        | :white_check_mark:  | :white_check_mark:  |
| `password`        | :white_check_mark:  | :white_check_mark:  |
| `instance`        | :white_check_mark:  | :white_check_mark:  |
| `factory_pid`     | :x:                 | :white_check_mark:  |
| `properties`      | :white_check_mark:  | :white_check_mark:  |
| `append`          | :white_check_mark:  | :white_check_mark:  |
| `apply_all`       | :white_check_mark:  | :white_check_mark:  |
| `include_missing` | :white_check_mark:  | :white_check_mark:  |
| `unique_fields`   | :x:                 | :white_check_mark:  |
| `count`           | :x:                 | :white_check_mark:  |
| `enforce_count`   | :x:                 | :white_check_mark:  |
| `force`           | :white_check_mark:  | :x:                 |

### Usage

#### Regular OSGi configs

```ruby
cq_osgi_config 'Root Mapping' do
  pid 'com.day.cq.commons.servlets.RootMappingServlet'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties('rootmapping.target' => '/welcome.html')

  action :create
end
```

`Root Mapping` resource sets `/` redirect to `/welcome.html` if it's not already set.

```ruby
cq_osgi_config 'Event Admin' do
  pid 'org.apache.felix.eventadmin.impl.EventAdmin'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  append true
  properties(
    'org.apache.felix.eventadmin.IgnoreTimeout' => ['com.example*']
  )

  action :create
end
```

`Event Admin` merges defined properties with the ones that are already set (because of `append` property). This is how
`Event Admin` will look like before:

| ID                                           | VALUE                                |
| -------------------------------------------- | ------------------------------------ |
| `org.apache.felix.eventadmin.ThreadPoolSize` | `20`                                 |
| `org.apache.felix.eventadmin.Timeout`        | `5000`                               |
| `org.apache.felix.eventadmin.RequireTopic`   | `true`                               |
| `org.apache.felix.eventadmin.IgnoreTimeout`  | `["org.apache.felix*","com.adobe*"]` |

and after Chef run:

| ID                                           | VALUE                                               |
| -------------------------------------------- | --------------------------------------------------- |
| `org.apache.felix.eventadmin.ThreadPoolSize` | `20`                                                |
| `org.apache.felix.eventadmin.Timeout`        | `5000`                                              |
| `org.apache.felix.eventadmin.RequireTopic`   | `true`                                              |
| `org.apache.felix.eventadmin.IgnoreTimeout`  | `["com.adobe*","com.example*","org.apache.felix*"]` |

```ruby
cq_osgi_config 'OAuth Twitter' do
  pid 'com.adobe.granite.auth.oauth.impl.TwitterProviderImpl'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'oauth.provider.id' => 'twitter'
  )

  action :delete
end
```

Properties of `OAuth Twitter` will be restored to default values if any of them was previously modified (explicitly
set).

```ruby
cq_osgi_config 'Promotion Manager' do
  pid 'com.adobe.cq.commerce.impl.promotion.PromotionManagerImpl'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  force true

  action :delete
end
```

`Promotion Manager` will behave as `OAuth Twitter` with one exception - it will happen on every Chef run due to `force`
property.

#### Factory OSGi configs

```ruby
cq_osgi_config 'Custom Logger' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  factory_pid 'org.apache.sling.commons.log.LogManager.factory.config'
  properties(
    'org.apache.sling.commons.log.level' => 'error',
    'org.apache.sling.commons.log.file' => 'logs/custom.log',
    'org.apache.sling.commons.log.pattern' =>
      '{0,date,dd.MM.yyyy HH:mm:ss.SSS} *{4}* [{2}] {3} {5}',
    'org.apache.sling.commons.log.names' => [
      'com.example.custom1',
      'com.example.custom2'
    ]
  )
  unique_fields ['org.apache.sling.commons.log.file']

  action :create
end
```

`Custom Logger` resource will create a new logger according to defined properties. `org.apache.sling.commons.log.file`
is a virtual identifier of given OSGi config instance (specified by user). If instance with such "ID" already exists
nothing happens. Otherwise a brand new configuration will be created. Please keep in mind that there's no need to
specify any UUID in resource definition.

```ruby
cq_osgi_config 'Job Queue' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  factory_pid 'org.apache.sling.event.jobs.QueueConfiguration'
  properties(
    'queue.name' => 'Granite Workflow Timeout Queue',
    'queue.type' => 'TOPIC_ROUND_ROBIN',
    'queue.topics' => ['com/adobe/granite/workflow/timeout/job'],
    'queue.maxparallel' => -1,
    'queue.retries' => 10,
    'queue.retrydelay' => 2000,
    'queue.priority' => 'MIN',
    'service.ranking' => 0
  )
  unique_fields ['queue.name']

  action :delete
end
```

`Job Queue` resource will delete factory instance of `org.apache.sling.event.jobs.QueueConfiguration` that has
`queue.name` set to `Granite Workflow Timeout Queue`. Presence of additional properties doesn't matter in this case and
will be completely ignored.

## cq_osgi_bundle

Adds ability to stop and start OSGi bundles

### Actions

- `stop` - stop given OSGi bundle if it is in `Active` state
- `start` - starts defined bundle, but only when it's in `Resolved` state

### Properties

- ( **String** ) `symbolic_name` - Symbolic name of the bundle, i.e. `com.company.example.abc`. If not explicitly
  defined resource name will be used as symbolic name
- ( **String** ) `username` - Instance username
- ( **String** ) `password` - Instance password
- ( **String** ) `instance` - Instance URL
- ( **Boolean** ) `rescue_mode` - Same meaning as for `cq_package`
- ( **Integer** ) `same_state_barrier` - Same meaning as for `cq_package`
- ( **Integer** ) `error_state_barrier` - Same meaning as for `cq_package`
- ( **Integer** ) `max_attempts` - Same meaning as for `cq_package`
- ( **Integer** ) `sleep_time` - Same meaning as for `cq_package`

### Usage

```ruby
cq_osgi_bundle 'Author: org.eclipse.equinox.region' do
  symbolic_name 'org.eclipse.equinox.region'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  same_state_barrier 3
  sleep_time 5

  action :stop
end
```

First example stops `org.eclipse.equinox.region` AEM author instance. Since there's just a few dependencies on this
bundle, number of post-stop checks have been limited, as there's no point to wait for so long.

```ruby
cq_osgi_bundle 'com.adobe.xmp.worker.files.native.fragment.linux' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"

  action :start
end
```

Second instance of `cq_osgi_bundle` is fairly simple, as it just starts
`com.adobe.xmp.worker.files.native.fragment.linux` bundle.

## cq_osgi_component

Please keep in mind that OSGi components used to get back to their original state after AEM instance restart. If you
disabled one, most probably it'll become enabled after instance restart.

### Actions

- `enable` - enable given OSGi component
- `disable` - disable defined OSGi component

### Properties

- ( **String** ) `pid` - Component PID
- ( **String** ) `username` - Instance username
- ( **String** ) `password` - Instance password
- ( **String** ) `instance` - Instance URL

### Usage

```ruby
cq_osgi_component 'Author: com.example.my.component' do
  pid 'com.example.my.component'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"

  action :enable
end

cq_osgi_component 'Author: com.project.email.servlet' do
  pid 'com.project.email.servlet'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"

  action :disable
end
```

Both examples are self-explanatory. First one enables `com.example.my.component` component if it's in `disabled` state.
Second one will disable `com.project.email.servlet` component, but only if it's state is not already `disabled`.

## cq_user

Exposes a resource for CQ/AEM user management. Supports:

- password updates
- profile updates (e-mail, job title, etc)
- status updates (activate/deactivate given user)

### Actions

- `modify` - use to modify an existing user. Action will be skipped if given user does not exist

### Properties

- ( **String** ) `id` - User ID (login)
- ( **String** ) `username` - Instance username
- ( **String** ) `password` - Instance password
- ( **String** ) `instance` - Instance URL
- ( **String** ) `email` - E-mail
- ( **String** ) `first_name` - First name
- ( **String** ) `last_name` - Last name
- ( **String** ) `phone_number` - Phone number
- ( **String** ) `job_title` - Job title
- ( **String** ) `street` - Street
- ( **String** ) `mobile` - Mobile
- ( **String** ) `city` - City
- ( **String** ) `postal_code` - Postal code
- ( **String** ) `country` - Country
- ( **String** ) `state` - State
- ( **String** ) `gender` - Gender
- ( **String** ) `about` - About section
- ( **String** ) `user_password` - Desired password for non-admin user specified by id property
- ( **Boolean** ) `enabled` - `true` by default, set to `false` to deactivate given user. Has no effect for admin user
- ( **String** ) `old_password` - Old password of admin user. Has no effect for non-admin ones

### Compatibility matrix

| Property        | `admin` user       | All other users    |
| --------------- | ------------------ | ------------------ |
| `id`            | :white_check_mark: | :white_check_mark: |
| `username`      | :white_check_mark: | :white_check_mark: |
| `password`      | :white_check_mark: | :white_check_mark: |
| `instance`      | :white_check_mark: | :white_check_mark: |
| `email`         | :white_check_mark: | :white_check_mark: |
| `first_name`    | :white_check_mark: | :white_check_mark: |
| `last_name`     | :white_check_mark: | :white_check_mark: |
| `phone_number`  | :white_check_mark: | :white_check_mark: |
| `job_title`     | :white_check_mark: | :white_check_mark: |
| `street`        | :white_check_mark: | :white_check_mark: |
| `mobile`        | :white_check_mark: | :white_check_mark: |
| `city`          | :white_check_mark: | :white_check_mark: |
| `postal_code`   | :white_check_mark: | :white_check_mark: |
| `country`       | :white_check_mark: | :white_check_mark: |
| `state`         | :white_check_mark: | :white_check_mark: |
| `gender`        | :white_check_mark: | :white_check_mark: |
| `about`         | :white_check_mark: | :white_check_mark: |
| `user_password` | :x:                | :white_check_mark: |
| `enabled`       | :x:                | :white_check_mark: |
| `old_password`  | :white_check_mark: | :x:                |

### Usage

```ruby
cq_user 'admin' do
  username node['cq']['author']['credentials']['login']
  password 'd4rk_kn1ght'
  instance "http://localhost:#{node['cq']['author']['port']}"

  first_name 'Bruce'
  last_name 'Wayne'
  old_password 'passw0rd'

  action :modify
end
```

Modify action on `cq_user 'admin'` resource will change CQ/AEM `admin` password to `d4rk_kn1ght` if the current one is
either `passw0rd` or `admin` (the latter is automatically checked if both `password` and `old_password` are incorrect).
Moreover `admin` first name and last name will be updated (to `Bruce` and `Wayne` respectively) if needed.

```ruby
cq_user 'author' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"

  first_name 'Peter'
  last_name 'Parker'
  job_title 'Spiderman'
  gender 'male'
  enabled false
  user_password 'sp1d3r'

  action :modify
end
```

Second example (`cq_user 'author'`) also updates user password, but this time
the old one doesn't have to be specified, as this operation will be executed on
admin rights (auth credentials: `username`/`password`). Additionally `auhtor`'s
profile will be updated and user will be disabled (`enabled false`), so you
won't be able to log in as this user anymore.

## cq_jcr

CRUD operations on JCR nodes.

### Actions

- `create` - creates new node under given path if it doesn't exist. Otherwise it modifies its properties if required
- `delete` - deletes node if it exists. Prints error otherwise
- `modify` - modifies properties of existing JCR node

### Properties

- ( **String** ) `path` - Node path
- ( **String** ) `username` - Instance username
- ( **String** ) `password` - Instance password
- ( **String** ) `instance` - Instance URL
- ( **Hash** ) `properties` - Node properties
- ( **Boolean** ) `append` - By default set to `true`. If full overwrite of properties is required please set append
  property to `false`. Applies only to `:create` and `:modify` actions

### Usage

```ruby
cq_jcr '/content/test_node' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'property_one' => 'first',
    'property_two' => 'second',
    'property_three' => ['item1', 'item2', 'item3']
  )

  action :create
end
```

Create action on `cq_jcr '/content/test_node'` will create such node with given properties if it doesn't exist yet.
Otherwise its properties will be updated if necessary. By default `append` is set to `true`, which means existing
properties of `/content/test_node` will stay untouched unless the same properties are specified in your `cq_jcr`
resource.

```ruby
cq_jcr '/content/geometrixx/en/products/jcr:content' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  append false
  properties(
    'jcr:primaryType' => 'cq:PageContent',
    'jcr:title' => 'New title',
    'subtitle' => 'New subtitle',
    'new_property' => 'Random value'
  )

  action :create
end
```

2nd example sets `append` property to `false`, which means that all properties except those specified in your resource
should be removed. It will act as a full overwrite (keep in mind that some properties are protected and can't be
deleted, moreover Sling API automatically adds things like `jcr:createdBy`).

```ruby
cq_jcr '/content/dam/geometrixx-media/articles/en/2012' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"

  action :delete
end
```

Next example is quite simple - `/content/dam/geometrixx-media/articles/en/2012` will get deleted if it exists. Otherwise
warning message will be printed.

```ruby
cq_jcr '/content/geometrixx/en/services/certification/jcr:content' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'jcr:title' => 'New Certification Services',
    'brand_new_prop' => 'ValueX'
  )

  action :modify
end
```

Last `cq_jcr` resource uses `:modify` action. It applies updates to existing nodes only. If specified path does not
exist warning message will be displayed.

## cq_start_guard

Allows you to wait for full AEM instance start before moving on with subsequent operations. It periodically sends HTTP
request to AEM and compares response (both status code and body) with expected state. As soon as defined requirements
are met the resource stops its job.

### Actions

- `nothing` - default action, does nothing :)
- `run` - verifies instance state according to defined properties. This action is _NOT idempotent_ by design and should
  be always triggered via `notify` from other resources

### Properties

- ( **String** ) `name` - Start guard name
- ( **String** ) `instance` - Instance URL
- ( **String** ) `path` - URL path that's requested to verify instance health
- ( **String** ) `expected_code` - Expected HTTP status code
- ( **String** ) `expected_body` - Expected string in HTTP response body
- ( **Integer** ) `timeout` - Maximum time in seconds before giving up
- ( **Integer** ) `http_timeout` - Maximum time for HTTP call
- ( **Integer** ) `interval` - Time in seconds between HTTP healthcheck request attempts

### Usage

```ruby
service 'cq64-author' do
  supports status: true, restart: true
  action :start

  notifies :run, "cq_start_guard[cq64-author]", :immediately
end

cq_start_guard 'cq64-author' do
  instance "http://localhost:#{node['cq']['author']['port']}"
  path node['cq']['author']['healthcheck']['resource']
  expected_code node['cq']['author']['healthcheck']['response_code']
  expected_body node['cq']['author']['healthcheck']['response_body']
  timeout node['cq']['service']['start_timeout']

  action :nothing
end
```

Whenever AEM gets (re)started run `cq_start_guard` and wait until `/libs/granite/core/content/login.html` returns 200
response code

```ruby
service 'cq64-author' do
  supports status: true, restart: true
  action :start

  notifies :run, "cq_start_guard[cq64-author]", :immediately
end

cq_start_guard 'cq64-author' do
  instance "http://localhost:#{node['cq']['author']['port']}"
  path '/bin/healthchecks/instance'
  expected_code '200'
  expected_body '{"status": "ok"}'
  timeout 900
  http_timeout 5
  interval 10

  action :nothing
end
```

Right after restart of `cq64-author` service send notification to `cq_start_guard` and wait until
`/bin/healthchecks/instance` returns 200 code and `{"status": "ok"}` JSON in the body. Don't spend more than 15 minutes
on such health check. Requests will be send every 10 seconds, however each HTTP call can't last more than 5 seconds.

## cq_clientlib_cache

This resource enables invalidation/rebuilt of internal clientlib cache in AEM. Please keep in mind that
`cq_clientlib_cache` is not idempotent and it is generally recommended to trigger it via `notify` from other resources.

### Actions

- `nothing` - default action
- `invalidate` - invalidates the entire clientlib cache
- `rebuild` - rebuilds all clientlibs (please keep in mind this operation usually takes at least a couple of minutes)

### Properties

- ( **String** ) `username` - Instance username
- ( **String** ) `password` - Instance password
- ( **String** ) `instance` - Instance URL

### Usage

```ruby
cq_package 'Custom AEM app' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source 'http://artifacts.example.org/app/1.0/myapp-1.0.zip'
  recursive_install true

  action :deploy

  notifies :invalidate, 'cq_clientlib_cache[invalidation]', :delayed
end

cq_clientlib_cache 'invalidation' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"

  action :nothing
end
```

# Testing

TBD

# Author

Jakub Wadolowski (<jakub.wadolowski@cognifide.com>)
