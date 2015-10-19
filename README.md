# CQ/AEM Chef cookbook

This is CQ/AEM cookbook that is primarily a library cookbook. It heavily uses
and relies on [CQ Unix Toolkit](https://github.com/Cognifide/CQ-Unix-Toolkit).

FYI, this cookbook is not called `aem-coobkook` because of the fact when I
started development there was no AEM yet and I simply like the old name much
better. Nowadays it seems to be already taken anyway, so I no longer have a
choice ;)

# Table of Contents

* [Supported platforms](#supported-platforms)
    * [Operating systems](#operating-systems)
    * [AEM/CQ versions](#aemcq-versions)
* [Attributes](#attributes)
    * [default.rb](#defaultrb)
    * [author.rb](#authorrb)
    * [publish.rb](#publishrb)
* [Recipes](#recipes)
    * [default.rb](#defaultrb-1)
    * [author.rb](#authorrb-1)
    * [publish.rb](#publishrb-1)
* [Custom Resources](#custom-resources)
    * [cq_package](#cq_package)
        * [Actions](#actions)
        * [Attributes](#attributes-1)
        * [Usage](#usage)
    * [cq_osgi_config](#cq_osgi_config)
        * [Actions](#actions-1)
        * [Attributes](#attributes-2)
        * [Compatibility matrix](#compatibility-matrix)
        * [Usage](#usage-1)
            * [Regular OSGi configs](#regular-osgi-configs)
            * [Factory OSGi configs](#factory-osgi-configs)
    * [cq_user](#cq_user)
        * [Actions](#actions-2)
        * [Attributes](#attributes-3)
        * [Compatibility matrix](#compatibility-matrix-1)
        * [Usage](#usage-2)
    * [cq_jcr](#cq_jcr)
        * [Actions](#actions-3)
        * [Attributes](#attributes-4)
        * [Usage](#usage-4)
* [Testing](#testing)
* [Authors](#authors)

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
* package specific details (name, group, version) are always extracted from
  `/META-INF/vault/properties.xml` inside ZIP file and/or CRX Package
  Manager API for already uploaded/installed packages, so you don't have to
  define that anywhere else. All you need is an URL to your package
* packages are automatically downloaded from remote (`http://`, `https://`) or
  local (`file://`) sources. If HTTP(S) source requires basic auth it is also
  supported (`http_user` and `http_pass` respectively for user and password)
* by default all packages are downloaded to Chef's cache (`/var/chef/cache`),
  but it can be easily reconfigured (`node['cq']['package_cache']`)
* `cq_package` resource is version aware, so defined actions are always
  executed for given package version
* installation process is considered finished only when both "foreground"
  (Package Manager) and "background" (OSGi bundle/component restarts) ones are
  over - no more 'wait until you see MESSAGE_X in `error.log` file'

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

### Attributes

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
    <tt>notifies</tt> on your package resource and more than a single action
    was defined (i.e. <tt>action [:upload, :install]</tt>), two notifications
    will be triggered (after <tt>:upload</tt> and <tt>:install</tt>
    respectively)</td>
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
    is not responding over HTTP. After CQ/AEM restart everything works
    perfectly fine again.
    This flag allows Chef to continue processing if it is not able to get OSGi
    bundles state 6 times in a row. In most (if not all) cases it should be
    combined with restart notification (please see examples below).
    It is highly discouraged to use this property, as 99% of CRX packages
    shouldn't require such configuration. Unfortunately that 1% does. This is
    rather a safety switch than a common pattern that should be used in every
    single case.
    Applies only to install and deploy actions.</td>
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

More comprehensive examples can be found in package test recipes:

* [recipes/_package_aem561.rb](recipes/_package_aem561.rb)
* [recipes/_package_aem600.rb](recipes/_package_aem600.rb)

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

  action :install

  notifies :restart, 'service[cq60-author]', :immediately
end
```

First `cq_package` resource will download Slice package from provided URL and
upload it to defined AEM Author instance.

Second resource does the same as the first one, but for Oak 1.0.13 hotfix. The
only difference is that provided URL requires basic auth, hence the `http_user`
and `http_pass` attributes.

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
result of this event all (or almost all) bundles will be turned off and
effectively instance will stop responding or start serving 404s for all
resources (including `/system/console`). The java process though will still be
running. The only solution to that problem is AEM restart, after which all work
perfectly fine again. Without `rescue_mode` property `cq_package` provider will
keep checking OSGi bundles to detect their stable state, but none of these
attempts will end successfully, as nothing is reachable over HTTP. After 30
requests Chef run will be aborted. If `rescue_mode` was activated (set to
`true`) then after 6 unsuccessful attempts an error will be printed and the
processing will be continued (restart of `cq60-author` service in this case).

7th & 8th `cq_package` resources explain how to deal with AEM instance
restarts after package installation.

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
will treat this as a single resource on resource collection, which means that
notify parameter will be silently merged to the resource with upload action
during compile phase.

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


### Attributes

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

Detailed examples can be found here:

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
properties. Nothing will happen when there's no such OSGi config.

# cq_user

Exposes a resource for CQ/AEM user management. Supports:

* password updates
* profile updates (e-mail, job title, etc)
* status updates (activate/deactivate given user)

## Actions

* `modify` - use to modify an existing user. Action will be skipped if given
  user does not exist

## Attributes

<table>
  <tr>
    <th>Attribute</th>
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
    attribute</td>
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

| Attribute       | `admin` user        | All other users     |
| --------------- | ------------------- | ------------------- |
| `id`            | :white_check_mark:  | :white_check_mark:  |
| `username`      | :white_check_mark:  | :white_check_mark:  |
| `password`      | :white_check_mark:  | :white_check_mark:  |
| `instance`      | :white_check_mark:  | :white_check_mark:  |
| `email`         | :white_check_mark:  | :white_check_mark:  |
| `first_name`    | :white_check_mark:  | :white_check_mark:  |
| `last_name`     | :white_check_mark:  | :white_check_mark:  |
| `phone_number`  | :white_check_mark:  | :white_check_mark:  |
| `job_title`     | :white_check_mark:  | :white_check_mark:  |
| `street`        | :white_check_mark:  | :white_check_mark:  |
| `mobile`        | :white_check_mark:  | :white_check_mark:  |
| `city`          | :white_check_mark:  | :white_check_mark:  |
| `postal_code`   | :white_check_mark:  | :white_check_mark:  |
| `country`       | :white_check_mark:  | :white_check_mark:  |
| `state`         | :white_check_mark:  | :white_check_mark:  |
| `gender`        | :white_check_mark:  | :white_check_mark:  |
| `about`         | :white_check_mark:  | :white_check_mark:  |
| `user_password` | :no_entry:          | :white_check_mark:  |
| `enabled`       | :no_entry:          | :white_check_mark:  |
| `old_password`  | :white_check_mark:  | :no_entry:          |

## Usage

More detailed examples are available [here](recipes/_users.rb).

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

Enables CRUD operations on JCR nodes. Currently supports:

* nodes creation
* nodes modification
* nodes deletion

## Actions

* `create` - creates new node under given path if it doesn't exist. Otherwise
  it modifies its properties if required
* `delete` - deletes node if it exists. Prints error otherwise
* `modify` - modifies properties of existing JCR node

## Attributes

<table>
  <tr>
    <th>Attribute</th>
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
    required please set <tt>append</tt> attribute to <tt>false</tt>. Applies
    only to <tt>:create</tt> and <tt>:modify</tt> actions</td>
  </tr>
</table>

## Usage

More examples of `cq_jcr` are available in [this](recipes/_jcr_nodes.rb)
recipe.

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

2nd example sets `append` attribute to `false`, which means that all
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

# Authors

Jakub Wadolowski (<jakub.wadolowski@cognifide.com>)
