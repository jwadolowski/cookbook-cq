# CQ/AEM Chef cookbook

This is CQ/AEM cookbook that is primarily a library cookbook. It heavily uses
and relies on [CQ Unix Toolkit](https://github.com/Cognifide/CQ-Unix-Toolkit).

Because I like CQ name better I decided to stick with the old naming schema.

# Supported platforms

## Operating systems

* CentOS/RHEL 6.x

## AEM/CQ versions

* AEM 5.6.x
* AEM 6.0.x

Most probably it should work with 5.5 (although cookbook wasn't tested on this
version), but not with 5.4 and any other previous version (because of API
changes).

# Attributes

## default.rb

TBD

## author.rb

TBD

## publish.rb

TBD

# Recipes

## default.rb

TBD

## author.rb

TBD

## publish.rb

TBD


# Lightweight Resource Providers

## cq_package

TBD

## cq_osgi_config

### Actions

For non-factory (regular) configs:

* `create` - updates already existing configuration
* `delete` - restores default settings of given OSGi config if all properties
  match to defined state. If you'd like to restore default settings regardless
  of current properties please use `force` parameter

For factory configs:

* `create` - creates a new factory config instance if none of existing ones
  match to defined state
* `delete` - deletes factory config instance if there's one that matches to
  defined state


### Parameter Attributes

<table>
  <tr>
    <th>Attribute</th>
    <th>Type</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><tt>pid</tt></td>
    <td>String</td>
    <td>Config name (PID)</td>
  </tr>
  <tr>
    <td><tt>factory_pid</tt></td>
    <td>String</td>
    <td>Factory PID</td>
  </tr>
  <tr>
    <td><tt>properties</tt></td>
    <td>Hash</td>
    <td>Key-value pairs that represents OSGi config properties</td>
  </tr>
  <tr>
    <td><tt>append</tt></td>
    <td>Boolean</td>
    <td>Append defined values to existing regular OSGi config</td>
  </tr>
  <tr>
    <td><tt>force</tt></td>
    <td>Boolean</td>
    <td>If <tt>true</tt>, defined OSGi config is deleted reagrdless of current
    settings. Applies only to regular OSGi configs. <b>WARNING</b>: this
    violates idempotence, so please use <tt>only_if</tt> or <tt>not_if</tt>
    block to prevent constant execution</td>
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

### Usage

More comprehensive examples can be found here:

* [recipes/_osgi_config_create_regular.rb](recipes/_osgi_config_create_regular.rb)
* [recipes/_osgi_config_create_factory.rb](recipes/_osgi_config_create_factory.rb)

Please keep in mind that all recipes above use
[definitions/osgi_config_wrapper.rb](definitions/osgi_config_wrapper.rb)
definition for testing purposes.

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

`Root Mapping` resource sets `/` redirect to `/welcome.html` if it's not
already set.

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

  action :create
end
```

`Custom Logger` resource will create a new logger according to defined
properties unless it is already present. There's no need to specify an UUID in
resource definition.

# Authors

Author:: Jakub Wadolowski (<jakub.wadolowski@cognifide.com>)
