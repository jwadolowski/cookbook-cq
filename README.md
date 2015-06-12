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

---

All LWRPs are idempotent, so action won't be taken if it is not required.

---

## cq_package

It allows for CRX package manipulation using CRX Package Manager API.

Key features:
* package specific details (name, group, version) are always extracted from its
  metadata (`/META-INF/vault/properties.xml` inside ZIP file and CRX Package
  Manager API for already uploaded/installed packages)
* all packages are downloaded to Chef's cache (by default: `/var/chef/cache`)
* `cq_package` resource is version aware, so defined actions are always
  executed for given package version
* installation process is considered finished only when both "foreground"
  (Package Manager) and the "background" (OSGi bundle/component restarts) ones
  are over - no more 'wait until you see MESSAGE_X in `error.log` file'

### Actions

* `upload` - uploads package to given CQ instance
* `install` - installs already uploaded package

### Parameter Attributes

<table>
  <tr>
    <th>Attribute</th>
    <th>Type</th>
    <th>Description</th>
  </tr>
  <tr>
    <td><tt>name</tt></td>
    <td>String</td>
    <td>Package name. Can be anything as long as it means something to you.
    Actual package name is extracted from provided ZIP file. Whenever you use
    <tt>notifies</tt> on your package resource and more than single action was
    defined (i.e. <tt> action [:upload, :install]</tt>), please make sure you
    named it uniquely to avoid unexpected behaviour, i.e. instance restart
    after package upload</td>
  </tr>
  <tr>
    <td><tt>source</tt></td>
    <td>String</td>
    <td>URL to ZIP package. Accepted protocols: <tt>file://</tt>,
    <tt>http://</tt>, <tt>https://</tt></td>
  </tr>
  <tr>
    <td><tt>recursive_install</tt></td>
    <td>Boolean</td>
    <td>Wheter to use recursive flag when installing packages (required for
    service packs and some hotfixes). Applies only to install action</td>
  </tr>
  <tr>
    <td><tt>checksum</tt></td>
    <td>String</td>
    <td>ZIP file checksum (passed through to <<tt>remote_file</tt> resource
    that is used under the hood by <tt>cq_package</tt> provider)</td>
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

Detailed examples can be found in package test recipes:

* [recipes/_package_aem561.rb](recipes/_package_aem561.rb)
* [recipes/_package_aem600.rb](recipes/_package_aem600.rb)

```ruby
cq_package "Slice 4.2.1" do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source 'https://oss.sonatype.org/content/groups/public/com/cognifide/slice'\
    '/slice-assembly/4.2.1/slice-assembly-4.2.1-cq.zip'

  action :upload
end

cq_package " Upgrade to Oak 1.0.13" do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source 'https://artifacts.example.com/aem/6.0.0/hotfixes'\
    '/cq-6.0.0-hotfix-6316-1.1.zip'
  http_user 'john'
  http_pass 'passw0rd'

  action :upload
end

cq_package "#{node['cq']['author']['run_mode']}: ACS AEM Commons 1.10.2" do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source 'https://github.com/Adobe-Consulting-Services/acs-aem-commons'\
    '/releases/download/acs-aem-commons-1.10.2'\
    '/acs-aem-commons-content-1.10.2.zip'

  action [:upload, :install]
end

cq_package "Author: Service Pack 2 (upload)" do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source node['cq']['packages']['aem6']['sp2']

  action :upload
end

cq_package "Author: Service Pack 2 (install)" do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source node['cq']['packages']['aem6']['sp2']
  recursive_install true

  action :install

  notifies :restart, 'service[cq60-author]', :immediately
end
```

First `cq_package` resource will download Slice package from provided URL to
Chef's cache and upload it to defined AEM Author instance.

Second resource does the same as the first one, but for Oak 1.0.13 hotfix. The
only difference is that provided URL requies basic auth, hence the `http_user`
and `http_pass` attributes.

Third package shows how to combine multiple actions in a single `cq_package`
resource usage.

4th & 5th `cq_package` resources presents how to deal with AEM instance
restarts after package installation as well as packages that require recursive
extraction. Please notice that both resources were named differently on purpose
to avoid resource merge and 2 restarts. If you'd use:

```ruby
cq_package "Author: Service Pack 2" do
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
cq_package "Author: Service Pack 2" do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  source node['cq']['packages']['aem6']['sp2']

  action :upload
end

cq_package "Author: Service Pack 2" do
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
will treat this as a single resource on resource collection - notify parameter
will be silently merged to the resource with upload action during compile
phase.

## cq_osgi_config

Provides an interface for CRUD operations in OSGi configs.

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
    <td>Set to true if you'd like to specify just a subset of original
    properties. For regular configs it means that your properties will be
    eventually merged with the ones that are already configured in AEM. Merged
    values will be used during idempotence test. Impact on factory configs is
    slightly different. Properties will be also merged in the end, but during
    idempotence test only values defined in your resource will be used, so
    please make sure it will be enogugh for unique identification</td>
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
| `append`      | :white_check_mark:  | :white_check_mark:  |
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
