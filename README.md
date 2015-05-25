# CQ/AEM Chef cookbook

This is CQ/AEM cookbook that is primarily a library cookbook.

Because I like CQ name better I decided to stick with the old naming schema.

# Supported platforms

## Operating systems

* CentOS/RHEL 6.x

## AEM versions

* AEM 5.6.x
* AEM 6.0.x

Most probably it should work with 5.5 (although cookbook wasn't tested on this
version), but not with 5.4 and any other previous version (because of API
changes).

# Attributes

# Recipes

# Lightweight Resource Providers

## cq_pacakge

## cq_osgi_config

### Actions

For non-factory (regular configs):

* `create` - updates already existing configuration
* `delete` - TBD

For factory configs:

* `create` - creates a new factory config instance if none of existing ones
  match to defined state
* `delete` - TBD


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

# License and Authors

Author:: Jakub Wadolowski (<jakub.wadolowski@cognifide.com>)
