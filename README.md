# CQ/AEM Chef cookbook

This cookbook deploys and configures Adobe Experience Manager (AEM), formerly
known as CQ.

FYI, it is not called `aem-coobkook`, because when I started development there
was no AEM yet (it was known as CQ at that time). Nowadays the `aem` name seems
to be taken anyways, so I no longer have a choice.

# Table of contents

* [Supported platforms](#supported-platforms)
    * [Operating systems](#operating-systems)
    * [Chef versions](#chef-versions)
    * [AEM/CQ versions](#aemcq-versions)
* [Getting started](#getting-started)
* [Attributes](#attributes)
    * [default.rb](#defaultrb)
    * [author.rb](#authorrb)
    * [publish.rb](#publishrb)
* [Recipes](#recipes)
    * [default.rb](#defaultrb-1)
    * [commons.rb](#commonsrb)
    * [author.rb](#authorrb-1)
    * [publish.rb](#publishrb-1)
* [Custom resources](#custom-resources)
    * [cq_package](#cq_package)
        * [Actions](#actions)
        * [Properties](#properties)
        * [Usage](#usage)
    * [cq_osgi_config](#cq_osgi_config)
        * [Actions](#actions-1)
        * [Properties](#properties-1)
        * [Compatibility matrix](#compatibility-matrix)
        * [Usage](#usage-1)
            * [Regular OSGi configs](#regular-osgi-configs)
            * [Factory OSGi configs](#factory-osgi-configs)
    * [cq_osgi_bundle](#cq_osgi_bundle)
        * [Actions](#actions-2)
        * [Properties](#properties-2)
        * [Usage](#usage-2)
    * [cq_osgi_component](#cq_osgi_component)
        * [Actions](#actions-3)
        * [Properties](#properties-3)
        * [Usage](#usage-3)
    * [cq_user](#cq_user)
        * [Actions](#actions-4)
        * [Properties](#properties-4)
        * [Compatibility matrix](#compatibility-matrix-1)
        * [Usage](#usage-4)
    * [cq_jcr](#cq_jcr)
        * [Actions](#actions-5)
        * [Properties](#properties-5)
        * [Usage](#usage-5)
* [Testing](#testing)
* [Author](#author)

# Supported platforms

## Operating systems

* CentOS/RHEL 6.x
* CentOS/RHEL 7.x

## Chef versions

* Chef 12.x

## AEM/CQ versions

* AEM 6.1.0
* AEM 6.2.0
* AEM 6.3.0
* AEM 6.4.0

# Getting started

TBD

# Attributes

For default values please refer to appropriate files.

## default.rb

---

To set Java related attributes please refer to [java
cookbook](https://github.com/agileorbit-cookbooks/java). By default it
installs Oracle's JDK7.

---

<table>
  <tr>
    <th>Attribute</th>
    <th>Type</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><tt>['cq']['user']</tt></td>
    <td>String</td>
    <td>System user for CQ/AEM</td>
  </tr>
  <tr>
    <td><tt>['cq']['user_uid']</tt></td>
    <td>String</td>
    <td>UID of CQ/AEM user</td>
  </tr>
  <tr>
    <td><tt>['cq']['user_comment']</tt></td>
    <td>String</td>
    <td>Comment/description of CQ/AEM user</td>
  </tr>
  <tr>
    <td><tt>['cq']['user_shell']</tt></td>
    <td>String</td>
    <td>Default shell of CQ/AEM user</td>
  </tr>
  <tr>
    <td><tt>['cq']['group']</tt></td>
    <td>String</td>
    <td>System group for CQ/AEM</td>
  </tr>
  <tr>
    <td><tt>['cq']['group_gid']</tt></td>
    <td>String</td>
    <td>GID of CQ/AEM group</td>
  </tr>
  <tr>
    <td><tt>['cq']['limits']['file_descriptors']</tt></td>
    <td>String</td>
    <td>Max number of open file descriptor for CQ/AEM user</td>
  </tr>
  <tr>
    <td><tt>['cq']['base_dir']</tt></td>
    <td>String</td>
    <td>Base directory for CQ/AEM instance(s)</td>
  </tr>
  <tr>
    <td><tt>['cq']['home_dir']</tt></td>
    <td>String</td>
    <td>Home directory under wich CQ/AEM instances are deployed</td>
  </tr>
  <tr>
    <td><tt>['cq']['version']</tt></td>
    <td>String</td>
    <td>CQ/AEM version</td>
  </tr>
  <tr>
    <td><tt>['cq']['custom_tmp_dir']</tt></td>
    <td>String</td>
    <td>Custom directory that JVM uses for temporary files</td>
  </tr>
  <tr>
    <td><tt>['cq']['jar']['url']</tt></td>
    <td>String</td>
    <td>URL from which CQ/AEM JAR file is downloaded</td>
  </tr>
  <tr>
    <td><tt>['cq']['jar']['checksum']</tt></td>
    <td>String</td>
    <td>SHA256 checksum of CQ/AEM JAR file</td>
  </tr>
  <tr>
    <td><tt>['cq']['license']['url']</tt></td>
    <td>String</td>
    <td>URL from which CQ/AEM license is downloaded</td>
  </tr>
  <tr>
    <td><tt>['cq']['license']['checksum']</tt></td>
    <td>String</td>
    <td>SHA256 checksum of CQ/AEM license file</td>
  </tr>
  <tr>
    <td><tt>['cq']['service']['start_timeout']</tt></td>
    <td>Fixnum</td>
    <td>Max number of seconds to wait until CQ/AEM instance is fully
    operational after service start</td>
  </tr>
  <tr>
    <td><tt>['cq']['service']['kill_delay']</tt></td>
    <td>Fixnum</td>
    <td>Max number of seconds for greceful instance stop before kill signal is
    sent to the process</td>
  </tr>
  <tr>
    <td><tt>['cq']['service']['restart_sleep']</tt></td>
    <td>Fixnum</td>
    <td>Number of seconds to wait between service stop and start</td>
  </tr>
  <tr>
    <td><tt>['cq']['init_template_cookbook']</tt></td>
    <td>String</td>
    <td>Cookbook which is a source for init script template</td>
  </tr>
  <tr>
    <td><tt>['cq']['conf_template_cookbook']</tt></td>
    <td>String</td>
    <td>Cookbook which is a source for conf file template</td>
  </tr>
</table>

## author.rb

All attributes in this file refer to CQ/AEM author instance (
`['cq']['author']` namespace).

<table>
  <tr>
    <th>Attribute</th>
    <th>Type</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><tt>['cq']['author']['run_mode']</tt></td>
    <td>String</td>
    <td>Instance run mode</td>
  </tr>
  <tr>
    <td><tt>['cq']['author']['port']</tt></td>
    <td>String</td>
    <td>Main port of CQ/AEM instance</td>
  </tr>
  <tr>
    <td><tt>['cq']['author']['jmx_ip']</tt></td>
    <td>String</td>
    <td>Value of <tt>-Djava.rmi.server.hostname</tt> JVM parameter. Requires
    reference to <tt>${CQ_JMX_IP}</tt> shell variable in
    <tt>['cq']['author']['jvm']['jmx_opts']</tt> attribute to be effective
    </td>
  </tr>
  <tr>
    <td><tt>['cq']['author']['jmx_port']</tt></td>
    <td>String</td>
    <td>Value of <tt>-Dcom.sun.management.jmxremote.port</tt> and/or
    <tt>-Dcom.sun.management.jmxremote.rmi.port</tt> JVM parameters. Requires
    reference to <tt>${CQ_JMX_PORT}</tt> shell variable in
    <tt>['cq']['author']['jvm']['jmx_opts']</tt> attribute to be effective
    </td>
  </tr>
  <tr>
    <td><tt>['cq']['author']['debug_ip']</tt></td>
    <td>String</td>
    <td>IP to listen on with debug interface. Requires reference to
    <tt>${CQ_DEBUG_IP}</tt> shell variable in
    <tt>['cq']['author']['jvm']['debug_opts']</tt> attribute to be effective
    </td>
  </tr>
  <tr>
    <td><tt>['cq']['author']['debug_port']</tt></td>
    <td>String</td>
    <td>Port of JVM debug interface. Requires reference to
    <tt>${CQ_DEBUG_PORT}</tt> shell variable in
    <tt>['cq']['author']['jvm']['debug_opts']</tt> attribute to be effective
    </td>
  </tr>
  <tr>
    <td><tt>['cq']['author']['credentials']['login']</tt></td>
    <td>String</td>
    <td>User that's used to perform actions agains your CQ/AEM instance. The
    most typical scenarios require <tt>admin</tt></td>
  </tr>
  <tr>
    <td><tt>['cq']['author']['credentials']['password']</tt></td>
    <td>String</td>
    <td>Passowrd of user specified in
    <tt>['cq']['author']['credentials']['login']</tt></td>
  </tr>
  <tr>
    <td><tt>['cq']['author']['jvm']['min_heap']</tt></td>
    <td>String</td>
    <td>Number of megabytes that's passed on to <tt>-Xms</tt> JVM parameter
    </td>
  </tr>
  <tr>
    <td><tt>['cq']['author']['jvm']['max_heap']</tt></td>
    <td>String</td>
    <td>Number of megabytes that's passed on to <tt>-Xmx</tt> JVM parameter
    </td>
  </tr>
  <tr>
    <td><tt>['cq']['author']['jvm']['max_perm_size']</tt></td>
    <td>String</td>
    <td>Number of megabytes that's passed on to <tt>-XX:MaxPermSize</tt> JVM
    parameter</td>
  </tr>
  <tr>
    <td><tt>['cq']['author']['jvm']['code_cache_size']</tt></td>
    <td>String</td>
    <td>Number of megabytes that's passed on to
    <tt>-XX:ReservedCodeCacheSize</tt> JVM parameter</td>
  </tr>
  <tr>
    <td><tt>['cq']['author']['jvm']['general_opts']</tt></td>
    <td>String</td>
    <td>Generic JVM parameters</td>
  </tr>
  <tr>
    <td><tt>['cq']['author']['jvm']['code_cache_opts']</tt></td>
    <td>String</td>
    <td>JVM parameters related to its code cache</td>
  </tr>
  <tr>
    <td><tt>['cq']['author']['jvm']['gc_opts']</tt></td>
    <td>String</td>
    <td>JVM parameters related to garbage collection</td>
  </tr>
  <tr>
    <td><tt>['cq']['author']['jvm']['jmx_opts']</tt></td>
    <td>String</td>
    <td>JVM parameres related to JMX settings</td>
  </tr>
  <tr>
    <td><tt>['cq']['author']['jvm']['debug_opts']</tt></td>
    <td>String</td>
    <td>JVM parameters related to debug interface</td>
  </tr>
  <tr>
    <td><tt>['cq']['author']['jvm']['crx_opts']</tt></td>
    <td>String</td>
    <td>CRX related JVM parameters</td>
  </tr>
  <tr>
    <td><tt>['cq']['author']['jvm']['extra_opts']</tt></td>
    <td>String</td>
    <td>All other JVM patameters</td>
  </tr>
  <tr>
    <td><tt>['cq']['author']['healthcheck']['resource']</tt></td>
    <td>String</td>
    <td>Resource that's queried during instance start to determine whether
    CQ/AEM is fully operational</td>
  </tr>
  <tr>
    <td><tt>['cq']['author']['healthcheck']['response_code']</tt></td>
    <td>String</td>
    <td>Expected HTTP status code of healthcheck resource</td>
  </tr>
</table>

## publish.rb

All attributes in this file refer to CQ/AEM publish instance (
`['cq']['publish']` namespace).

<table>
  <tr>
    <th>Attribute</th>
    <th>Type</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><tt>['cq']['publish']['run_mode']</tt></td>
    <td>String</td>
    <td>Instance run mode</td>
  </tr>
  <tr>
    <td><tt>['cq']['publish']['port']</tt></td>
    <td>String</td>
    <td>Main port of CQ/AEM instance</td>
  </tr>
  <tr>
    <td><tt>['cq']['publish']['jmx_ip']</tt></td>
    <td>String</td>
    <td>Value of <tt>-Djava.rmi.server.hostname</tt> JVM parameter. Requires
    reference to <tt>${CQ_JMX_IP}</tt> shell variable in
    <tt>['cq']['publish']['jvm']['jmx_opts']</tt> attribute to be effective
    </td>
  </tr>
  <tr>
    <td><tt>['cq']['publish']['jmx_port']</tt></td>
    <td>String</td>
    <td>Value of <tt>-Dcom.sun.management.jmxremote.port</tt> and/or
    <tt>-Dcom.sun.management.jmxremote.rmi.port</tt> JVM parameters. Requires
    reference to <tt>${CQ_JMX_PORT}</tt> shell variable in
    <tt>['cq']['publish']['jvm']['jmx_opts']</tt> attribute to be effective
    </td>
  </tr>
  <tr>
    <td><tt>['cq']['publish']['debug_ip']</tt></td>
    <td>String</td>
    <td>IP to listen on with debug interface. Requires reference to
    <tt>${CQ_DEBUG_IP}</tt> shell variable in
    <tt>['cq']['publish']['jvm']['debug_opts']</tt> attribute to be effective
    </td>
  </tr>
  <tr>
    <td><tt>['cq']['publish']['debug_port']</tt></td>
    <td>String</td>
    <td>Port of JVM debug interface. Requires reference to
    <tt>${CQ_DEBUG_PORT}</tt> shell variable in
    <tt>['cq']['publish']['jvm']['debug_opts']</tt> attribute to be effective
    </td>
  </tr>
  <tr>
    <td><tt>['cq']['publish']['credentials']['login']</tt></td>
    <td>String</td>
    <td>User that's used to perform actions agains your CQ/AEM instance. The
    most typical scenarios require <tt>admin</tt></td>
  </tr>
  <tr>
    <td><tt>['cq']['publish']['credentials']['password']</tt></td>
    <td>String</td>
    <td>Passowrd of user specified in
    <tt>['cq']['publish']['credentials']['login']</tt></td>
  </tr>
  <tr>
    <td><tt>['cq']['publish']['jvm']['min_heap']</tt></td>
    <td>String</td>
    <td>Number of megabytes that's passed on to <tt>-Xms</tt> JVM parameter
    </td>
  </tr>
  <tr>
    <td><tt>['cq']['publish']['jvm']['max_heap']</tt></td>
    <td>String</td>
    <td>Number of megabytes that's passed on to <tt>-Xmx</tt> JVM parameter
    </td>
  </tr>
  <tr>
    <td><tt>['cq']['publish']['jvm']['max_perm_size']</tt></td>
    <td>String</td>
    <td>Number of megabytes that's passed on to <tt>-XX:MaxPermSize</tt> JVM
    parameter</td>
  </tr>
  <tr>
    <td><tt>['cq']['publish']['jvm']['code_cache_size']</tt></td>
    <td>String</td>
    <td>Number of megabytes that's passed on to
    <tt>-XX:ReservedCodeCacheSize</tt> JVM parameter</td>
  </tr>
  <tr>
    <td><tt>['cq']['publish']['jvm']['general_opts']</tt></td>
    <td>String</td>
    <td>Generic JVM parameters</td>
  </tr>
  <tr>
    <td><tt>['cq']['publish']['jvm']['code_cache_opts']</tt></td>
    <td>String</td>
    <td>JVM parameters related to its code cache</td>
  </tr>
  <tr>
    <td><tt>['cq']['publish']['jvm']['gc_opts']</tt></td>
    <td>String</td>
    <td>JVM parameters related to garbage collection</td>
  </tr>
  <tr>
    <td><tt>['cq']['publish']['jvm']['jmx_opts']</tt></td>
    <td>String</td>
    <td>JVM parameres related to JMX settings</td>
  </tr>
  <tr>
    <td><tt>['cq']['publish']['jvm']['debug_opts']</tt></td>
    <td>String</td>
    <td>JVM parameters related to debug interface</td>
  </tr>
  <tr>
    <td><tt>['cq']['publish']['jvm']['crx_opts']</tt></td>
    <td>String</td>
    <td>CRX related JVM parameters</td>
  </tr>
  <tr>
    <td><tt>['cq']['publish']['jvm']['extra_opts']</tt></td>
    <td>String</td>
    <td>All other JVM patameters</td>
  </tr>
  <tr>
    <td><tt>['cq']['publish']['healthcheck']['resource']</tt></td>
    <td>String</td>
    <td>Resource that's queried during instance start to determine whether
    CQ/AEM is fully operational</td>
  </tr>
  <tr>
    <td><tt>['cq']['publish']['healthcheck']['response_code']</tt></td>
    <td>String</td>
    <td>Expected HTTP status code of healthcheck resource</td>
  </tr>
</table>

# Recipes

## default.rb

Installs core dependencies (Ruby gems and OS packages).

## commons.rb

Takes care of common elements of every CQ/AEM deployment, including:

* system user and its configuration
* required directory structure
* Java installation
* CQ Unix Toolkit installation

## author.rb

Installs CQ/AEM author instance.

## publish.rb

Installs CQ/AEM publish instance.

# Custom resources

---

All CQ/AEM related resource are idempotent, so action won't be taken if not
required.

---

---

Whenever you need to deploy 2 or more CQ/AEM instances on a single server
please make sure you named all your custom resources differently, as you may
get unexpected results otherwise (i.e. when CQ/AEM restart is required
afterwards). Please find `cq_package` example below:

*Bad*:

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

*Good*:

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

---

## cq_package

Allows for CRX package manipulation using CRX Package Manager API.

Key features:

* package specific details (name, group, version) are always extracted from ZIP
  file (`/META-INF/vault/properties.xml`), so you don't have to define that
  anywhere else. All you need is an URL to your package
* `cq_package` identifies packages by name/group/version properties
* packages are automatically downloaded from remote (`http://`, `https://`) or
  local (`file://`) sources. If HTTP(S) source requires basic auth please use
  `http_user` and `http_pass`
* by default all packages are downloaded to Chef's cache (`/var/chef/cache`)
* installation process is considered finished only when both "foreground"
  (Package Manager) and "background" (OSGi bundle/component restarts) ones are
  over - no more 'wait until you see X in `error.log`'

### Actions

---

If you'd like to upload and install a package, in most cases please use
`deploy` action instead of combined `upload` and `install`. Detailed
explanation can be found below.

---

* `upload` - uploads package to given CQ instance
* `install` - installs already uploaded package
* `deploy` - uploads and installs given package as a single action. This action
  is quicker than separate `upload` + `install` as less healthchecks have to be
  executed
* `uninstall` - uninstalls given CQ package
* `delete` - deletes given CQ package

### Properties

<table>
  <tr>
    <th>Property</th>
    <th>Type</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><tt>name</tt></td>
    <td>String</td>
    <td>Package name. Can be anything as long as it means something to you.
    Actual package name is extracted from provided ZIP file. Whenever you use
    <tt>notifies</tt> on your package resource and more than a single action
    was defined (i.e. <tt>action [:upload, :install]</tt>), two notifications
    will be triggered (after <tt>:upload</tt> and <tt>:install</tt>
    respectively)</td>
  </tr>
  <tr>
    <td><tt>username</tt></td>
    <td>String</td>
    <td>Instance username</td>
  </tr>
  <tr>
    <td><tt>password</tt></td>
    <td>String</td>
    <td>Instance password</td>
  </tr>
  <tr>
    <td><tt>instance</tt></td>
    <td>String</td>
    <td>Instance URL</td>
  </tr>
  <tr>
    <td><tt>source</tt></td>
    <td>String</td>
    <td>URL to ZIP package. Accepted protocols: <tt>file://</tt>,
    <tt>http://</tt>, <tt>https://</tt></td>
  </tr>
  <tr>
    <td><tt>http_user</tt></td>
    <td>String</td>
    <td>HTTP basic auth user. Use whenever <tt>source</tt> requires such
    authentication</td>
  </tr>
  <tr>
    <td><tt>http_pass</tt></td>
    <td>String</td>
    <td>HTTP basic auth password. Use whenever <tt>source</tt> requires such
    authentication</td>
  </tr>
  <tr>
    <td><tt>recursive_install</tt></td>
    <td>Boolean</td>
    <td>Whether to use recursive flag when installing packages (required for
    service packs and some hotfixes). Applies only to install and deploy
    actions</td>
  </tr>
  <tr>
    <td><tt>rescue_mode</tt></td>
    <td>Boolean</td>
    <td>Some packages may cause shutdown of the entire OSGi because of
    dependecy (i.e. cycle) or bundle priority issues. In such case after
    package installation java process is still running, however the instance
    is not responding over HTTP. After CQ/AEM restart everyting works
    perfectly fine again.
    This flag allows Chef to continue processing if it is not able to get OSGi
    bundles state <tt>error_state_barrier</tt> times in a row.
    In most (if not all) cases it should be combined with restart notification
    (please see examples below).
    It is highly discouraged to use this property, as 99% of CRX packages
    shouldn't require such configuration. Unfortunately that 1% does. This is
    rather a safety switch than a common pattern that should be used in every
    single case.
    Applies only to install and deploy actions.</td>
  </tr>
  <tr>
    <td><tt>checksum</tt></td>
    <td>String</td>
    <td>ZIP file checksum (passed through to <tt>remote_file</tt> resource
    that is used under the hood by <tt>cq_package</tt> provider)</td>
  </tr>
  <tr>
    <td><tt>same_state_barrier</tt></td>
    <td>Integer</td>
    <td>How many times in a row the same OSGi state should occur after package
    (un)installation to consider this process successful. Default is 6</td>
  </tr>
  <tr>
    <td><tt>error_state_barrier</tt></td>
    <td>Integer</td>
    <td>How many times in a row the OSGi console was unavailable after package
    (un)installation. Useful only when combined with <tt>rescue_mode</tt>. By
    default set to 6</td>
  </tr>
  <tr>
    <td><tt>max_attempts</tt></td>
    <td>Integer</td>
    <td>Number of attempts while waiting for stable OSGi state after package
    (un)installation. Set to 30 by default</td>
  </tr>
  <tr>
    <td><tt>sleep_time</tt></td>
    <td>Integer</td>
    <td>Sleep time between OSGi status checks (in seconds) after package
    (un)installation. Set to 10 by default</td>
  </tr>
</table>

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

cq_package 'ACS AEM Commons 1.10.2' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source 'https://github.com/Adobe-Consulting-Services/acs-aem-commons'\
    '/releases/download/acs-aem-commons-1.10.2'\
    '/acs-aem-commons-content-1.10.2.zip'

  action [:upload, :install]
end

cq_package 'AEM6 hotfix 6316' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source node['cq']['packages']['aem6']['hf6316']
  recursive_install true

  action :deploy

  notifies :restart, 'service[cq60-author]', :immediately
end

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

First `cq_package` resource will download Slice package from provided URL and
upload it to defined AEM Author instance.

Second resource does the same as the first one, but for Oak 1.0.13 hotfix. The
only difference is that provided URL requires basic auth, hence the `http_user`
and `http_pass` properties.

Third package shows how to combine multiple actions in a single `cq_package`
resource usage.

4th `cq_package` presents how to use `deploy` action that combines both
`upload` and `install` in a single execution. This is preferred way of doing
package deployment, in particular for those that require AEM service restart
as soon as installation is completed. `recursive_install` was also used here,
which is required for majority of hotfixes and every service pack.

Next example describes usage of `uninstall` action. In this particular case
operation was executed against Geometrixx package.

6th `cq_package` presents usage of `rescue_mode` property. Imagine that this
package provides new OSGi bundles and right after its installation some serious
issue occurs (i.e. unresolvable OSGi dependency, conflict or cycle). As a
result of this event all bundles will be turned off and effectively instance
will stop responding or start serving 404s for all resources (including
`/system/console`). The java process though will still be running. The only
solution to that problem is AEM restart, after which all work perfectly fine
again. Without `rescue_mode` property `cq_package` provider will keep checking
OSGi bundles to detect their stable state, but none of these attempts will end
successfully, as nothing is reachable over HTTP. Eventually Chef run will be
aborted. If `rescue_mode` was activated (set to `true`) then after
`error_state_barrier` unsuccessful attempts an error will be printed and the
processing will be continued (restart of `cq60-author` service in this case).

7th & 8th `cq_package` resources explain how to deal with AEM instance
restarts after package installation and tune post installation OSGi
stability checks.

Moreover it explains how to use combination of `upload` and `install` instead
of `deploy`. Such procedure might be required sometimes, i.e. when some extra
steps have to be done after package upload, but before its installation.

Please notice that both resources were named differently on purpose
to avoid resource merge and 2 restarts. If you'd use:

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

In the first case during compile phase Chef will generate 2 resources with the
same name, but different actions.

In second example restart still will be triggered after upload, even if it's
not explicitly defined during 1st usage (upload action). The reason is quite
simple - both resources are named the same (`Author: Service Pack 2`) and Chef
will treat this as a single resource on resource collection. It means that
notify parameter will be silently merged to the resource with upload action
during compile phase.

## cq_osgi_config

Provides an interface for CRUD operations in OSGi configs.

### Actions

For regular (non-factory, single instance) configs:

* `create` - updates already existing configuration
* `delete` - restores default settings of given OSGi config

For factory configs:

* `create` - creates a new factory instance if none of existing ones match to
  defined state
* `delete` - deletes factory config instance if there's one that matches to
  defined state


### Properties

<table>
  <tr>
    <th>Property</th>
    <th>Type</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><tt>pid</tt></td>
    <td>String</td>
    <td>Config name (PID). Relevant to regular configs only</td>
  </tr>
  <tr>
    <td><tt>username</tt></td>
    <td>String</td>
    <td>Instance username</td>
  </tr>
  <tr>
    <td><tt>password</tt></td>
    <td>String</td>
    <td>Instance password</td>
  </tr>
  <tr>
    <td><tt>instance</tt></td>
    <td>String</td>
    <td>Instance URL</td>
  </tr>
  <tr>
    <td><tt>factory_pid</tt></td>
    <td>String</td>
    <td>Factory PID</td>
  </tr>
  <tr>
    <td><tt>properties</tt></td>
    <td>Hash</td>
    <td>Key-value pairs that represent OSGi config properties</td>
  </tr>
  <tr>
    <td><tt>append</tt></td>
    <td>Boolean</td>
    <td>If set to <tt>true</tt> arrays will be merged. Use if you'd like to
    specify just a subset of array elements. <tt>false</tt> by default. Has no
    impact on other property types (String, Fixnum, etc)</td>
  </tr>
  <tr>
    <td><tt>apply_all</tt></td>
    <td>Boolean</td>
    <td>If <tt>true</tt> all properties defined in a <tt>cq_osgi_config</tt>
    resource will be used when applying OSGi configuration (despite of the fact
    just a subset differs). Example: 5 properties were defined as
    <tt>properties</tt>, 3 of them require update, but all of them will be set.
    <tt>false</tt> by default
    </td>
  </tr>
  <tr>
    <td><tt>include_missing</tt></td>
    <td>Boolean</td>
    <td>Properties that were NOT defined by user, but exist in OSGi will be
    included as a part of an update if this property is set to <tt>true</tt>
    for regular OSGi configs. For factory configs it bahaves almost the same.
    If new instance needs to be created then defaults defined in factory PID
    will be used. In case of existing instance update, all missing properties
    will be based on properties defined in that instance. This is
    <b>recommended</b> property when you'd like to edit pre-existing factory
    or regular configs. <tt>true</tt> by default</td>
  </tr>
  <tr>
    <td><tt>unique_fields</tt></td>
    <td>Array</td>
    <td>Property names/keys that define uniqueness of given config. Applicable
    to factory configs only. By deafult all available property keys will be
    used (defined by factory config on AEM instance). User doesn't need to
    define that at all, unless you want to cherry pick particular config. It's
    generally <b>recommended</b> to specify this for every factory OSGi config.
    Example: <tt>log.name</tt> key needs to stay unique for your config</td>
  </tr>
  <tr>
    <td><tt>count</tt></td>
    <td>Fixnum</td>
    <td>Number of duplicated instances of given OSGi configuration. 1 by
    default. Applicable to factory configs only. Useful when duplicated
    instances are allowed, i.e. each instance specify some sort of a worker and
    every single one of them has exactly the same set of properties
    </td>
  </tr>
  <tr>
    <td><tt>enforce_count</tt></td>
    <td>Boolean</td>
    <td>Reduces number of duplicated configs if more than <tt>count</tt> has
    been found. Applicable to factory configs only. <tt>false</tt> by default
    </td>
  </tr>
  <tr>
    <td><tt>force</tt></td>
    <td>Boolean</td>
    <td>If <tt>true</tt>, defined OSGi config is deleted/updated reagrdless of
    current settings. Applies to regular OSGi configs only. This violates
    idempotence, so please use <tt>only_if</tt> or <tt>not_if</tt> blocks to
    prevent constant execution</td>
  </tr>
  <tr>
    <td><tt>rescue_mode</tt></td>
    <td>Boolean</td>
    <td>Some config operations may cause shutdown of the entire OSGi because of
    dependecy (i.e. cycle) or bundle/component priority issues. In such case
    after config update java process is still running, however the instance
    is not responding over HTTP. After CQ/AEM restart everyting works
    perfectly fine again.
    This flag allows Chef to continue processing if it is not able to get OSGi
    component state <tt>error_state_barrier</tt> times in a row.
    In most (if not all) cases it should be combined with AEM restart
    notification.
    It is highly discouraged to use this property, as 99% of OSGi configs
    shouldn't require such configuration. Unfortunately that 1% does. This is
    rather a safety switch than a common pattern that should be used in every
    single case.
    </td>
  </tr>
  <tr>
    <td><tt>same_state_barrier</tt></td>
    <td>Integer</td>
    <td>How many times in a row the same OSGi component state should occur
    after configuration update to consider this process successful. 3 by
    default</td>
  </tr>
  <tr>
    <td><tt>error_state_barrier</tt></td>
    <td>Integer</td>
    <td>How many times in a row the OSGi console was unavailable after OSGi
    config update. Useful only when combined with <tt>rescue_mode</tt>. 3 by
    default</td>
  </tr>
  <tr>
    <td><tt>max_attempts</tt></td>
    <td>Integer</td>
    <td>Number of attempts while waiting for stable OSGi state after OSGi
    config update. 60 by default</td>
  </tr>
  <tr>
    <td><tt>sleep_time</tt></td>
    <td>Integer</td>
    <td>Sleep time between OSGi component status checks (in seconds) after
    config update. 2 by default</td>
  </tr>
</table>

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

cq_osgi_config 'Promotion Manager' do
  pid 'com.adobe.cq.commerce.impl.promotion.PromotionManagerImpl'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  force true

  action :delete
end
```

`Root Mapping` resource sets `/` redirect to `/welcome.html` if it's not
already set.

`Event Admin` merges defined properties with the ones that are already set
(because of `append` property). This is how `Event Admin` will look like
before:

| ID                                         | VALUE |
| ------------------------------------------ | ----- |
| org.apache.felix.eventadmin.ThreadPoolSize | 20    |
| org.apache.felix.eventadmin.Timeout        | 5000  |
| org.apache.felix.eventadmin.RequireTopic   | true  |
| org.apache.felix.eventadmin.IgnoreTimeout  | ["org.apache.felix\*","com.adobe\*"] |

and after Chef run:

| ID                                         | VALUE |
| ------------------------------------------ | ----- |
| org.apache.felix.eventadmin.ThreadPoolSize | 20    |
| org.apache.felix.eventadmin.Timeout        | 5000  |
| org.apache.felix.eventadmin.RequireTopic   | true  |
| org.apache.felix.eventadmin.IgnoreTimeout  | ["com.adobe\*","com.example\*","org.apache.felix\*"] |

Properties of `OAuth Twitter` will be restored to default values if any of them
was previously modified (explicitly set).

`Promotion Manager` will behave as `OAuth Twitter` with one exception - it will
happen on every Chef run due to `force` property.

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

`Custom Logger` resource will create a new logger according to defined
properties. `org.apache.sling.commons.log.file` is a virtual identifier of
given OSGi config instance (specified by user). If instance with such "ID"
already exists nothing happens. Otherwise a brand new configuration will be
created.
Please keep in mind that there's no need to specify any UUID in resource definition.


`Job Queue` resource will delete factory instance of
`org.apache.sling.event.jobs.QueueConfiguration` that has `queue.name` set to
`Granite Workflow Timeout Queue`. Presence of additional properties doesn't
matter in this case and will be completely ignored.

# cq_osgi_bundle

Adds ability to stop and start OSGi bundles

## Actions

* `stop` - stop given OSGi bundle if it is in `Active` state
* `start` - starts defined bundle, but only when it's in `Resolved` state

## Properties

<table>
  <tr>
    <th>Property</th>
    <th>Type</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><tt>symbolic_name</tt></td>
    <td>String</td>
    <td>Symbolic name of the bundle, i.e. <tt>com.company.example.abc</tt>. If
    not explicitly defined resource name will be used as symbolic name</td>
  </tr>
  <tr>
    <td><tt>username</tt></td>
    <td>String</td>
    <td>Instance username</td>
  </tr>
  <tr>
    <td><tt>password</tt></td>
    <td>String</td>
    <td>Instance password</td>
  </tr>
  <tr>
    <td><tt>instance</tt></td>
    <td>String</td>
    <td>Instance URL</td>
  </tr>
  <tr>
    <td><tt>rescue_mode</tt></td>
    <td>Boolean</td>
    <td>Same meaning as for <tt>cq_package</tt></td>
  </tr>
  <tr>
    <td><tt>same_state_barrier</tt></td>
    <td>Integer</td>
    <td>Same meaning as for <tt>cq_package</tt></td>
  </tr>
  <tr>
    <td><tt>error_state_barrier</tt></td>
    <td>Integer</td>
    <td>Same meaning as for <tt>cq_package</tt></td>
  </tr>
  <tr>
    <td><tt>max_attempts</tt></td>
    <td>Integer</td>
    <td>Same meaning as for <tt>cq_package</tt></td>
  </tr>
  <tr>
    <td><tt>sleep_time</tt></td>
    <td>Integer</td>
    <td>Same meaning as for <tt>cq_package</tt></td>
  </tr>
</table>

## Usage

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

cq_osgi_bundle 'com.adobe.xmp.worker.files.native.fragment.linux' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"

  action :start
end
```

First example stops `org.eclipse.equinox.region` AEM author instance. Since
there's just a few dependencies on this bundle, number of post-stop checks
have been limited, as there's no point to wait for so long.

Second instance of `cq_osgi_bundle` is fairly simple, as it just starts
`com.adobe.xmp.worker.files.native.fragment.linux` bundle.

# cq_osgi_component

Management of OSGi components

## Actions

* `enable` - enable given OSGi component
* `disable` - disable defined OSGi component

## Properties

<table>
  <tr>
    <th>Property</th>
    <th>Type</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><tt>pid</tt></td>
    <td>String</td>
    <td>Component PID</td>
  </tr>
  <tr>
    <td><tt>username</tt></td>
    <td>String</td>
    <td>Instance username</td>
  </tr>
  <tr>
    <td><tt>password</tt></td>
    <td>String</td>
    <td>Instance password</td>
  </tr>
  <tr>
    <td><tt>instance</tt></td>
    <td>String</td>
    <td>Instance URL</td>
  </tr>
</table>

## Usage

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

Both examples are self-explanatory. First one enables
`com.example.my.component` component if it's in `disabled` state. Second one
will disable `com.project.email.servlet` component, but only if it's state is
not already `disabled`.

---

Please keep in mind that OSGi components used to get back to their original
state after AEM instance restart. So if you disabled one, most probably it'll
become enabled after instance restart.

---

# cq_user

Exposes a resource for CQ/AEM user management. Supports:

* password updates
* profile updates (e-mail, job title, etc)
* status updates (activate/deactivate given user)

## Actions

* `modify` - use to modify an existing user. Action will be skipped if given
  user does not exist

## Properties

<table>
  <tr>
    <th>Property</th>
    <th>Type</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><tt>id</tt></td>
    <td>String</td>
    <td>User ID (login)</td>
  </tr>
  <tr>
    <td><tt>username</tt></td>
    <td>String</td>
    <td>Instance username</td>
  </tr>
  <tr>
    <td><tt>password</tt></td>
    <td>String</td>
    <td>Instance password</td>
  </tr>
  <tr>
    <td><tt>instance</tt></td>
    <td>String</td>
    <td>Instance URL</td>
  </tr>
  <tr>
    <td><tt>email</tt></td>
    <td>String</td>
    <td>E-mail</td>
  </tr>
  <tr>
    <td><tt>first_name</tt></td>
    <td>String</td>
    <td>First name</td>
  </tr>
  <tr>
    <td><tt>last_name</tt></td>
    <td>String</td>
    <td>Last name</td>
  </tr>
  <tr>
    <td><tt>phone_number</tt></td>
    <td>String</td>
    <td>Phone number</td>
  </tr>
  <tr>
    <td><tt>job_title</tt></td>
    <td>String</td>
    <td>Job title</td>
  </tr>
  <tr>
    <td><tt>street</tt></td>
    <td>String</td>
    <td>Street</td>
  </tr>
  <tr>
    <td><tt>mobile</tt></td>
    <td>String</td>
    <td>Mobile</td>
  </tr>
  <tr>
    <td><tt>city</tt></td>
    <td>String</td>
    <td>City</td>
  </tr>
  <tr>
    <td><tt>postal_code</tt></td>
    <td>String</td>
    <td>Postal code</td>
  </tr>
  <tr>
    <td><tt>country</tt></td>
    <td>String</td>
    <td>Country</td>
  </tr>
  <tr>
    <td><tt>state</tt></td>
    <td>String</td>
    <td>State</td>
  </tr>
  <tr>
    <td><tt>gender</tt></td>
    <td>String</td>
    <td>Gender</td>
  </tr>
  <tr>
    <td><tt>about</tt></td>
    <td>String</td>
    <td>About section</td>
  </tr>
  <tr>
    <td><tt>user_password</tt></td>
    <td>String</td>
    <td>Desired password for non-admin user specified by <tt>id</tt>
    property</td>
  </tr>
  <tr>
    <td><tt>enabled</tt></td>
    <td>Boolean</td>
    <td>True by default, set to false to deactive given user. Has no effect
    for admin user</td>
  </tr>
  <tr>
    <td><tt>old_password</tt></td>
    <td>String</td>
    <td>Old password of admin user. Has no effect for non-admin ones</td>
  </tr>
</table>

## Compatibility matrix

| Property        | `admin` user        | All other users    |
| --------------- | ------------------- | ------------------ |
| `id`            | :white_check_mark:  | :white_check_mark: |
| `username`      | :white_check_mark:  | :white_check_mark: |
| `password`      | :white_check_mark:  | :white_check_mark: |
| `instance`      | :white_check_mark:  | :white_check_mark: |
| `email`         | :white_check_mark:  | :white_check_mark: |
| `first_name`    | :white_check_mark:  | :white_check_mark: |
| `last_name`     | :white_check_mark:  | :white_check_mark: |
| `phone_number`  | :white_check_mark:  | :white_check_mark: |
| `job_title`     | :white_check_mark:  | :white_check_mark: |
| `street`        | :white_check_mark:  | :white_check_mark: |
| `mobile`        | :white_check_mark:  | :white_check_mark: |
| `city`          | :white_check_mark:  | :white_check_mark: |
| `postal_code`   | :white_check_mark:  | :white_check_mark: |
| `country`       | :white_check_mark:  | :white_check_mark: |
| `state`         | :white_check_mark:  | :white_check_mark: |
| `gender`        | :white_check_mark:  | :white_check_mark: |
| `about`         | :white_check_mark:  | :white_check_mark: |
| `user_password` | :x:                 | :white_check_mark: |
| `enabled`       | :x:                 | :white_check_mark: |
| `old_password`  | :white_check_mark:  | :x:                |

## Usage

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

Modify action on `cq_user 'admin'` resource will change CQ/AEM admin's password
to `d4rk_kn1ght` if the current one is either `passw0rd` or `admin` (the latter
is automatically checked if both `password` and `old_password` are incorrect).
Moreover admin's first name and last name will be updated (to `Bruce` and
`Wayne` respectively) if needed.

Second example (`cq_user 'author'`) also updates user password, but this time
the old one doesn't have to be specified, as this operation will be executed on
admin rights (auth credentials: `username`/`password`). Additionally `auhtor`'s
profile will be updated and user will be disabled (`enabled false`), so you
won't be able to log in as this user anymore.

# cq_jcr

CRUD operations on JCR nodes.

## Actions

* `create` - creates new node under given path if it doesn't exist. Otherwise
  it modifies its properties if required
* `delete` - deletes node if it exists. Prints error otherwise
* `modify` - modifies properties of existing JCR node

## Properties

<table>
  <tr>
    <th>Property</th>
    <th>Type</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><tt>path</tt></td>
    <td>String</td>
    <td>Node path</td>
  </tr>
  <tr>
    <td><tt>username</tt></td>
    <td>String</td>
    <td>Instance username</td>
  </tr>
  <tr>
    <td><tt>password</tt></td>
    <td>String</td>
    <td>Instance password</td>
  </tr>
  <tr>
    <td><tt>instance</tt></td>
    <td>String</td>
    <td>Instance URL</td>
  </tr>
  <tr>
    <td><tt>properties</tt></td>
    <td>Hash</td>
    <td>Node properties</td>
  </tr>
  <tr>
    <td><tt>append</tt></td>
    <td>Boolean</td>
    <td>By default set to <tt>true</tt>. If full overwrite of properties is
    required please set <tt>append</tt> property to <tt>false</tt>. Applies
    only to <tt>:create</tt> and <tt>:modify</tt> actions</td>
  </tr>
</table>

## Usage

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

cq_jcr '/content/dam/geometrixx-media/articles/en/2012' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"

  action :delete
end

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

Create action on `cq_jcr '/content/test_node'` will create such node with
given properties if it doesn't exist yet. Otherwise its properties will be
updated if necessary. By default `append` is set to `true`, which means
existing properties of `/content/test_node` will stay untouched unless the same
properties are specified in your `cq_jcr` resource.

2nd example sets `append` property to `false`, which means that all
properties except those specified in your resource should be removed. It will
act as a full overwrite (keep in mind that some properties are protected and
can't be deleted, moreover Sling API automatically adds things like
`jcr:createdBy`).

Next example is very simple - `/content/dam/geometrixx-media/articles/en/2012`
will get deleted if it exists. Otherwise warning message will be printed.

Last `cq_jcr` resource uses `:modify` action. It applies updates to existing
nodes only. If specified path does not exist warning message will be
displayed.

# Testing

TBD

# Author

Jakub Wadolowski (<jakub.wadolowski@cognifide.com>)
