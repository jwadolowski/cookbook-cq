# v1.2.7 (2019-09-05)

* All crypto JAR regexes updated to keep things consistent

# v1.2.6 (2019-09-05)

* Regex gruop removed, as full path to crypto JAR file is expected

# v1.2.5 (2019-09-05)

* Crypto JAR regex fine-tuning

# v1.2.4 (2019-09-05)

* Regex responsible for crypto JAR extraction updated to address AEM 6.1 regression

# v1.2.3 (2019-09-04)

* Logging bugfix - incorrect reference to local variable

# v1.2.2 (2019-08-08)

* [#75](https://github.com/jwadolowski/cookbook-cq/pull/76) OSGi component validation fix

# v1.2.1 (2019-05-08)

* [#75](https://github.com/jwadolowski/cookbook-cq/pull/75) Pin version of multipart-post gem for backwards
  compatibility with pre 2.5 Ruby versions

# v1.2.0 (2018-12-02)

* [#68](https://github.com/jwadolowski/cookbook-cq/pull/68) New resource: `cq_start_guard`
* [#69](https://github.com/jwadolowski/cookbook-cq/pull/69) `cq_start_guard` docs
* [#71](https://github.com/jwadolowski/cookbook-cq/pull/71) Documentation improvements
* [#72](https://github.com/jwadolowski/cookbook-cq/pull/72) New resource: `cq_clientlib_cache`

# v1.1.2 (2018-07-02)

* [#67](https://github.com/jwadolowski/cookbook-cq/pull/67) Amazon Linux support

# v1.1.1 (2018-04-27)

* Bugfix in RHEL detection

# v1.1.0 (2018-04-17)

* [#66](https://github.com/jwadolowski/cookbook-cq/pull/66) systemd service (default on CentOS/RHEL 7)
* [#66](https://github.com/jwadolowski/cookbook-cq/pull/66) Chef 13.x and 14.x support
* AEM 5.6.1 and 6.0.0 are no longer supported

# v1.0.1 (2018-04-11)

* Git reference to CQ UNIX Toolkit cookbook was removed from `Berksfile`, as it
  is available on Supermarket now

# v1.0.0 (2018-04-10)

First public release of CQ cookbook!

Supported AEM versions:

* AEM 5.6.1
* AEM 6.0.0
* AEM 6.1.0
* AEM 6.2.0
* AEM 6.3.0
* AEM 6.4.0

Supported operating systems:

* CentOS/RHEL 6.x
* CentOS/RHEL 7.x

Custom resources:

* `cq_package`
* `cq_osgi_config`
* `cq_osgi_bundle`
* `cq_osgi_component`
* `cq_user`
* `cq_jcr`

At the time of writing `chef-client` 12.20.3 is recommended. Official support
for 13.x and 14.x will be added in the upcoming releases.
