# CQ/AEM Chef cookbook

This is CQ/AEM cookbook that is primarily a library cookbook. It heavily uses
and relies on [CQ Unix Toolkit](https://github.com/Cognifide/CQ-Unix-Toolkit).

FYI, this cookbook is not called `aem-coobkook` because of the fact when I
started development there was no AEM yet and I simply like CQ name much better.

# Supported platforms

## Operating systems

* CentOS/RHEL 6.x

## AEM/CQ versions

* AEM 5.6.1
* AEM 6.0.0

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

### Compatibility matrix

| Attribute     | Regular OSGi config | Factory OSGi config |
| ------------- | ------------------- | ------------------- |
| `pid`         | :white_check_mark:  | :white_check_mark:  |
| `factory_pid` | :no_entry:          | :white_check_mark:  |
| `properties`  | :white_check_mark:  | :white_check_mark:  |
| `append`      | :white_check_mark:  | :no_entry:          |
| `force`       | :white_check_mark:  | :no_entry:          |
| `username`    | :white_check_mark:  | :white_check_mark:  |
| `password`    | :white_check_mark:  | :white_check_mark:  |
| `instance`    | :white_check_mark:  | :white_check_mark:  |

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
  properties({})

  action :delete
end
```

`Root Mapping` resource sets `/` redirect to `/welcome.html` if it's not
already set.

`Event Admin` merges defined properties with the ones that are already set
(because of `append` attribute). This is how `Event Admin` will look like
before:

| ID                                         | VALUE |
| ------------------------------------------ | ----- |
| org.apache.felix.eventadmin.ThreadPoolSize | 20    |
| org.apache.felix.eventadmin.Timeout        | 5000  |
| org.apache.felix.eventadmin.RequireTopic   | true  |
| org.apache.felix.eventadmin.IgnoreTimeout  | ["org.apache.felix\*","org.apache.sling\*","com.day\*","com.adobe\*"] |

and after Chef run:

| ID                                         | VALUE |
| ------------------------------------------ | ----- |
| org.apache.felix.eventadmin.ThreadPoolSize | 20    |
| org.apache.felix.eventadmin.Timeout        | 5000  |
| org.apache.felix.eventadmin.RequireTopic   | true  |
| org.apache.felix.eventadmin.IgnoreTimeout  | ["com.adobe\*","com.day\*","com.example\*","org.apache.felix\*","org.apache.sling\*"] |

`OAuth Twitter` will be deleted (restore to the defaults, as this is regular
OSGi config) only if properties match: `oauth.provider.id` is set to
`oauth.provider.id`.

`Promotion Manager` will be deleted (restored to defaults) regardless of its
current settings because of `force` flag.

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

cq_osgi_config 'Jobs Queue' do
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

  action :delete
end

```

`Custom Logger` resource will create a new logger according to defined
properties unless it is already present. There's no need to specify an UUID in
resource definition.

`Jobs Queue` resource will delete a factory instance of
`org.apache.sling.event.jobs.QueueConfiguration` that matches to defined
properties. When there's no such instance already no action will be performed.

# Testing

TBD

# Authors

Author:: Jakub Wadolowski (<jakub.wadolowski@cognifide.com>)
