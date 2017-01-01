# -----------------------------------------------------------------------------
# Regular configs (create)
#
# | Item            | Values        |
# | --------------- | ------------- |
# | Keys            | 1 or N        |
# | Values          | 1 or N        |
# | Append          | true or false |
# | Apply All       | true or false |
# | Force           | true or false |
# | All properties  | true or false |
#
# -----------------------------------------------------------------------------

# | Keys | Values | Append | Apply All | Force | All properties |
# | ---- | ------ | ------ | --------- | ----- | -------------- |
# | 1    | 1      | 0      | 0         | 0     | 1              |

# Original:
#
# {
#   "pid": "com.day.cq.dam.s7dam.common.S7damDamChangeEventListener",
#   "title": "Adobe CQ s7dam Dam Listener",
#   "properties": {
#     "cq.dam.s7dam.damchangeeventlistener.enabled": {
#       "name": "Enabled",
#       "optional": false,
#       "is_set": false,
#       "type": 11,
#       "value": "true",
#     }
#   }
# }
#
cq_osgi_config 'com.day.cq.dam.s7dam.common.S7damDamChangeEventListener' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'cq.dam.s7dam.damchangeeventlistener.enabled' => false
  )

  action :create
end

# Original:
#
# {
#   "pid": "com.day.cq.dam.scene7.impl.Scene7ConfigurationEventListener",
#   "title": "Adobe CQ Scene7 Configuration Listener",
#   "properties": {
#     "cq.dam.scene7.configurationeventlistener.enabled": {
#       "name": "Enabled",
#       "optional": false,
#       "is_set": true,
#       "type": 11,
#       "value": true,
#     }
#   }
# }
#
cq_osgi_config 'com.day.cq.dam.scene7.impl.Scene7ConfigurationEventListener' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'cq.dam.scene7.configurationeventlistener.enabled' => false
  )

  action :create
end

# | Keys | Values | Append | Apply All | Force | All properties |
# | ---- | ------ | ------ | --------- | ----- | -------------- |
# | 1    | 1      | 0      | 0         | 0     | 0              |

# Original:
#
# {
#   "pid": "org.apache.sling.engine.impl.SlingMainServlet",
#   "title": "Apache Sling Main Servlet",
#   "properties": {
#     "sling.max.calls": {
#       "name": "Number of Calls per Request",
#       "optional": false,
#       "is_set": true,
#       "type": 3,
#       "value": 1500,
#     },
#     "sling.max.inclusions": {
#       "name": "Recursion Depth",
#       "optional": false,
#       "is_set": false,
#       "type": 3,
#       "value": "50",
#     },
#     "sling.trace.allow": {
#       "name": "Allow the HTTP TRACE method",
#       "optional": false,
#       "is_set": false,
#       "type": 11,
#       "value": "false",
#     },
#     "sling.filter.compat.mode": {
#       "name": "Filter Compat Mode",
#       "optional": false,
#       "is_set": false,
#       "type": 11,
#       "value": "false",
#     },
#     "sling.max.record.requests": {
#       "name": "Number of Requests to Record",
#       "optional": false,
#       "is_set": false,
#       "type": 3,
#       "value": "20",
#     },
#     "sling.store.pattern.requests": {
#       "name": "Recorded Request Path Patterns",
#       "optional": false,
#       "is_set": false,
#       "type": 1,
#       "values": [],
#     },
#     "sling.serverinfo": {
#       "name": "Server Info",
#       "optional": false,
#       "is_set": false,
#       "type": 1,
#       "value": "",
#     },
#     "sling.additional.response.headers": {
#       "name": "Additional response headers",
#       "optional": false,
#       "is_set": false,
#       "type": 1,
#       "values": [
#         "X-Content-Type-Options=nosniff"
#       ],
#     }
#   }
# }
#
cq_osgi_config 'org.apache.sling.engine.impl.SlingMainServlet' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties('sling.max.record.requests' => 60)

  action :create
end

# | Keys | Values | Append | Apply All | Force | All properties |
# | ---- | ------ | ------ | --------- | ----- | -------------- |
# | 1    | N      | 0      | 0         | 0     | 1              |

# Original:
#
# {
#   "pid": "com.day.cq.wcm.foundation.impl.AdaptiveImageComponentServlet",
#   "title": "Adobe CQ Adaptive Image Component Servlet",
#   "properties": {
#     "adapt.supported.widths": {
#       "name": "Supported Widths",
#       "optional": false,
#       "is_set": false,
#       "type": 1,
#       "values": [
#         "320",
#         "480",
#         "476",
#         "620"
#       ]
#     }
#   }
#
cq_osgi_config 'AdaptiveImageComponentServlet' do
  pid 'com.day.cq.wcm.foundation.impl.AdaptiveImageComponentServlet'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'adapt.supported.widths' => %w(325 480 476 620 720 1080)
  )

  action :create
end

# Original:
#
# {
#   "pid": "com.adobe.cq.media.publishing.dps.impl.contentsync.DPSPagesUpdateHandler",
#   "title": "Adobe CQ Media DPS Pages Update Handler",
#   "properties": {
#     "cq.pagesupdatehandler.imageresourcetypes": {
#       "name": "cq.pagesupdatehandler.imageresourcetypes.name",
#       "optional": false,
#       "is_set": false,
#       "type": 1,
#       "values": [
#         "foundation/components/image"
#       ]
#     }
#   }
# }
#
cq_osgi_config 'DPSPagesUpdateHandler' do
  pid 'com.adobe.cq.media.publishing.dps.impl.contentsync.'\
    'DPSPagesUpdateHandler'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'cq.pagesupdatehandler.imageresourcetypes' => [
      'foundation/components/image',
      'foundation/components/test'
    ]
  )

  action :create
end

# | Keys | Values | Append | Apply All | Force | All properties |
# | ---- | ------ | ------ | --------- | ----- | -------------- |
# | 1    | N      | 1      | 0         | 0     | 1              |

# Original:
#
# {
#   "pid": "com.adobe.cq.media.publishing.dps.impl.contentsync.DPSSubPagesUpdateHandler",
#   "title": "Adobe CQ Media DPS Sub Pages Update Handler",
#   "properties": {
#     "cq.pagesupdatehandler.imageresourcetypes": {
#       "name": "cq.pagesupdatehandler.imageresourcetypes.name",
#       "optional": false,
#       "is_set": false,
#       "type": 1,
#       "values": [
#         "foundation/components/image"
#       ]
#     }
#   }
# }
#
cq_osgi_config 'DPSSubPagesUpdateHandler' do
  pid 'com.adobe.cq.media.publishing.dps.impl.contentsync.'\
    'DPSSubPagesUpdateHandler'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'cq.pagesupdatehandler.imageresourcetypes' => ['test/append/value']
  )
  append true

  action :create
end

# Original:
# {
#   "pid": "com.day.cq.dam.scene7.impl.Scene7AssetMimeTypeServiceImpl",
#   "title": "Adobe CQ Scene7 Asset MIME type Service",
#   "properties": {
#     "cq.dam.scene7.assetmimetypeservice.mapping": {
#       "name": "MIME Type mapping",
#       "optional": false,
#       "is_set": false,
#       "type": 1,
#       "values": [
#         "Generic=image/s7asset",
#         "Template=image/s7template",
#         "Flash=image/s7flashtemplate",
#         "Image=image/*",
#         "Image.jpeg=image/jpeg",
#         "Video=video/*",
#         "Video.mp4=video/mp4",
#         "Video.f4v=video/mp4",
#         "Video.flv=video/x-flv",
#         "PDF=application/pdf"
#       ]
#     }
#   }
# }
#
cq_osgi_config 'Scene7AssetMimeTypeServiceImpl' do
  pid 'com.day.cq.dam.scene7.impl.Scene7AssetMimeTypeServiceImpl'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'cq.dam.scene7.assetmimetypeservice.mapping' => [
      'Image=image/jpeg',
      'Image=image/png'
    ]
  )
  append true

  action :create
end

# | Keys | Values | Append | Apply All | Force | All properties |
# | ---- | ------ | ------ | --------- | ----- | -------------- |
# | N    | N      | 0      | 0         | 0     | 0              |

# Original:
#
# {
#   "pid": "com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl",
#   "title": "Day CQ Link Checker Service",
#   "properties": {
#     "scheduler.period": {
#       "name": "Scheduler Period",
#       "optional": false,
#       "is_set": false,
#       "type": 2,
#       "value": "5",
#     },
#     "scheduler.concurrent": {
#       "name": "scheduler.concurrent.name",
#       "optional": false,
#       "is_set": false,
#       "type": 11,
#       "value": "false",
#     },
#     "service.bad_link_tolerance_interval": {
#       "name": "Bad Link Tolerance Interval",
#       "optional": false,
#       "is_set": true,
#       "type": 3,
#       "value": 48,
#     },
#     "service.check_override_patterns": {
#       "name": "Link Check Override Patterns",
#       "optional": false,
#       "is_set": true,
#       "type": 1,
#       "values": [
#         "^system/"
#       ],
#     },
#     "service.cache_broken_internal_links": {
#       "name": "Cache Broken Internal Links",
#       "optional": false,
#       "is_set": false,
#       "type": 11,
#       "value": "false",
#     },
#     "service.special_link_prefix": {
#       "name": "Special Link Prefixes",
#       "optional": false,
#       "is_set": true,
#       "type": 1,
#       "values": [
#         "javascript:",
#         "data:",
#         "mailto:",
#         "#",
#         "<!--",
#         "${"
#       ],
#     },
#     "service.special_link_patterns": {
#       "name": "Special Link Patterns",
#       "optional": false,
#       "is_set": true,
#       "type": 1,
#       "value": "",
#     }
#   }
# }
#
cq_osgi_config 'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'service.bad_link_tolerance_interval' => '24',
    'service.check_override_patterns' => ['^system/', '^qwerty/'],
    'service.cache_broken_internal_links' => true,
    'service.special_link_prefix' => [
      'javascript:', 'data:', 'mailto:', 'rx:', '#', '<!--', '${', 'z:'
    ]
  )
  include_missing false

  action :create
end

# | Keys | Values | Append | Apply All | Force | All properties |
# | ---- | ------ | ------ | --------- | ----- | -------------- |
# | N    | N      | 0      | 0         | 0     | 1              |

# Original:
#
# {
#   "pid": "com.day.cq.dam.core.impl.servlet.HealthCheckServlet",
#   "title": "Day CQ DAM Health Check Servlet",
#   "properties": {
#     "sling.servlet.paths": {
#       "name": "sling.servlet.paths.name",
#       "optional": false,
#       "is_set": false,
#       "type": 1,
#       "value": "/libs/dam/health_check",
#     },
#     "sling.servlet.methods": {
#       "name": "sling.servlet.methods.name",
#       "optional": false,
#       "is_set": false,
#       "type": 1,
#       "values": [
#         "GET",
#         "POST"
#       ],
#     },
#     "sling.servlet.extensions": {
#       "name": "sling.servlet.extensions.name",
#       "optional": false,
#       "is_set": false,
#       "type": 1,
#       "value": "json",
#     },
#     "cq.dam.sync.workflow.id": {
#       "name": "Sync Workflow Model Id",
#       "optional": false,
#       "is_set": false,
#       "type": 1,
#       "value": "/etc/workflow/models/dam/dam_asset_syncer_and/jcr:content/model",
#     },
#     "cq.dam.sync.folder.types": {
#       "name": "Foldernode types",
#       "optional": false,
#       "is_set": false,
#       "type": 1,
#       "values": [
#         "nt:folder",
#         "sling:Folder",
#         "cq:Page"
#       ],
#     }
#   }
# }
#
cq_osgi_config 'com.day.cq.dam.core.impl.servlet.HealthCheckServlet' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'sling.servlet.methods' => ['GET', 'POST', 'CUSTOM', '-stop', '-i NJECT'],
    'sling.servlet.extensions' => 'json',
    'cq.dam.sync.workflow.id' => '/some/path/to/model',
    'cq.dam.sync.folder.types' => [
      'sth', '-u Z', '-uZ', '-u', '-p Y', '-pY', '-p', '-i X', '-iX', '-i'
    ]
  )

  action :create
end

# | Keys | Values | Append | Apply All | Force | All properties |
# | ---- | ------ | ------ | --------- | ----- | -------------- |
# | N    | N      | 1      | 0         | 0     | 0              |

# Original:
# {
#   "pid": "org.apache.felix.eventadmin.impl.EventAdmin",
#   "title": "Apache Felix Event Admin Implementation",
#   "properties": {
#     "org.apache.felix.eventadmin.ThreadPoolSize": {
#       "name": "Thread Pool Size",
#       "optional": false,
#       "is_set": false,
#       "type": 3,
#       "value": "20",
#     },
#     "org.apache.felix.eventadmin.AsyncToSyncThreadRatio": {
#       "name": "Async/sync Thread Pool Ratio",
#       "optional": false,
#       "is_set": false,
#       "type": 7,
#       "value": "0.5",
#     },
#     "org.apache.felix.eventadmin.Timeout": {
#       "name": "Timeout",
#       "optional": false,
#       "is_set": false,
#       "type": 3,
#       "value": "5000",
#     },
#     "org.apache.felix.eventadmin.RequireTopic": {
#       "name": "Require Topic",
#       "optional": false,
#       "is_set": false,
#       "type": 11,
#       "value": "true",
#     },
#     "org.apache.felix.eventadmin.IgnoreTimeout": {
#       "name": "Ignore Timeouts",
#       "optional": false,
#       "is_set": true,
#       "type": 1,
#       "values": [
#         "org.apache.felix*",
#         "org.apache.sling*",
#         "com.day*",
#         "com.adobe*"
#       ],
#     },
#     "org.apache.felix.eventadmin.IgnoreTopic": {
#       "name": "Ignore Topics",
#       "optional": false,
#       "is_set": false,
#       "type": 1,
#       "values": [],
#     }
#   }
# }
#
cq_osgi_config 'org.apache.felix.eventadmin.impl.EventAdmin' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'org.apache.felix.eventadmin.IgnoreTimeout' => ['com.example*'],
    'not.existing.key' => 'value1'
  )
  append true

  action :create
end

# | Keys | Values | Append | Apply All | Force | All properties |
# | ---- | ------ | ------ | --------- | ----- | -------------- |
# | N    | N      | 0      | 1         | 0     | 1              |

# Original:
# {
#   "pid": "com.adobe.granite.queries.impl.explain.query.ExplainQueryServlet",
#   "title": "Adobe Granite - Explain Query Servlet",
#   "description": "End-point for Apache Jackrabbit Oak query explanations.",
#   "properties": {
#     "log.logger-names": {
#       "name": "Query Logger Names",
#       "optional": false,
#       "is_set": false,
#       "type": 1,
#       "values": [
#         "org.apache.jackrabbit.oak.query",
#         "org.apache.jackrabbit.oak.plugins.index"
#       ],
#     },
#     "log.pattern": {
#       "name": "Log Pattern",
#       "optional": false,
#       "is_set": false,
#       "type": 1,
#       "value": "%msg%n",
#     },
#     "log.message-count-limit": {
#       "name": "Log Limit",
#       "optional": false,
#       "is_set": false,
#       "type": 3,
#       "value": "100",
#     },
#     "logging.enabled": {
#       "name": "Logging Enabled",
#       "optional": false,
#       "is_set": false,
#       "type": 11,
#       "value": "false",
#     }
#   }
# }
#
cq_osgi_config 'ExplainQueryServlet' do
  pid 'com.adobe.granite.queries.impl.explain.query.ExplainQueryServlet'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'log.logger-names' => [
      'org.apache.jackrabbit.oak.query',
      'org.apache.jackrabbit.oak.plugins.index'
    ],
    'log.pattern' => '%msg%n',
    'log.message-count-limit' => 150,
    'logging.enabled' => false
  )
  apply_all true

  action :create
end

# | Keys | Values | Append | Apply All | Force | All properties |
# | ---- | ------ | ------ | --------- | ----- | -------------- |
# | N    | N      | 0      | 0         | 1     | 1              |

# Original:
# {
#   "pid": "com.day.cq.wcm.foundation.forms.impl.MailServlet",
#   "title": "Adobe CQ Form Mail Servlet",
#   "properties": {
#     "resource.whitelist": {
#       "name": "Resource Whitelist",
#       "optional": false,
#       "is_set": false,
#       "type": 1,
#       "values": [
#         "/content",
#         "/home"
#       ],
#     },
#     "resource.blacklist": {
#       "name": "Resource Blacklist",
#       "optional": false,
#       "is_set": false,
#       "type": 1,
#       "value": "/content/usergenerated",
#     }
#   }
# }
#
cq_osgi_config 'com.day.cq.wcm.foundation.forms.impl.MailServlet' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'resource.whitelist' => %w(/content /home /test1 /test2)
  )
  force true

  action :create
end

# -----------------------------------------------------------------------------
# Regular configs (delete)
# -----------------------------------------------------------------------------

# Original:
# {
#   "pid": "com.adobe.cq.wcm.launches.impl.LaunchesEventHandler",
#   "title": "Adobe CQ Launches Event Handler",
#   "description": "An event handler specific to CQ Launches",
#   "properties": {
#     "event.filter": {
#       "name": "event.filter.name",
#       "optional": false,
#       "is_set": false,
#       "type": 1,
#       "value": "(!(event.application=*))",
#       "description": "event.filter.description (event.filter)"
#     },
#     "launches.eventhandler.threadpool.maxsize": {
#       "name": "Background Thread Pool Size",
#       "optional": false,
#       "is_set": false,
#       "type": 3,
#       "value": "5",
#     },
#     "launches.eventhandler.threadpool.priority": {
#       "name": "Background Thread Priority",
#       "optional": false,
#       "is_set": false,
#       "type": {
#         "labels": [
#           "Normal",
#           "Maximal",
#           "Minimal"
#         ],
#         "values": [
#           "NORM",
#           "MAX",
#           "MIN"
#         ]
#       },
#       "value": "MIN",
#     },
#     "launches.eventhandler.updatelastmodification": {
#       "name": "Update last modification",
#       "optional": false,
#       "is_set": false,
#       "type": 11,
#       "value": "false",
#     }
#   }
# }
#
cq_osgi_config 'com.adobe.cq.wcm.launches.impl.LaunchesEventHandler' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'launches.eventhandler.threadpool.maxsize' => 100,
    'launches.eventhandler.threadpool.priority' => 'MAX'
  )

  action [:create, :delete]
end

# Original:
# {
#   "pid": "com.adobe.cq.commerce.impl.promotion.PromotionManagerImpl",
#   "title": "Adobe CQ Commerce Promotion Manager",
#   "properties": {
#     "cq.commerce.promotion.root": {
#       "name": "Promotions Root",
#       "optional": false,
#       "is_set": false,
#       "type": 1,
#       "value": "/content/campaigns",
#     }
#   }
# }
#
cq_osgi_config 'com.adobe.cq.commerce.impl.promotion.PromotionManagerImpl' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"

  action :delete
end

# Original:
#
# {
#   "pid": "com.adobe.granite.auth.oauth.impl.TwitterProviderImpl",
#   "title": "Adobe Granite OAuth Twitter Provider",
#   "description": "Default Twitter OAuth Provider",
#   "properties": {
#     "oauth.provider.id": {
#       "name": "Provider ID",
#       "optional": false,
#       "is_set": false,
#       "type": 1,
#       "value": "twitter",
#       "description": "Assign a unique Provider ID (oauth.provider.id)"
#     }
#   }
# }
cq_osgi_config 'com.adobe.granite.auth.oauth.impl.TwitterProviderImpl' do
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  force true

  action :delete
end

# -----------------------------------------------------------------------------
# Factory configs (create)
#
# | Item                          | Values        |
# | ----------------------------- | ------------- |
# | Apply All and Include missing | true or false |
# | Unique fields                 | empty or 1+   |
# | Count                         | 1 or N        |
# | Enforce count                 | true or false |
#
# -----------------------------------------------------------------------------

# | Apply All | Unique fields | Count | Enforce count |
# | --------- | ------------- | ----- | ------------- |
# | 0         | 0             | 1     | 0             |
cq_osgi_config 'com.adobe.granite.monitoring.impl.ScriptConfigImpl' do
  factory_pid 'com.adobe.granite.monitoring.impl.ScriptConfigImpl'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'script.filename' => 'test-script.sh',
    'script.display' => 'Fancy Script',
    'script.path' => '/path/to/not/exisitng/script.sh',
    'script.platform' => [
      'dev7', 'prod1', '-platform1', '-p aaa', '-uat17', '-u bbb', '-v111',
      '-v ccc', '-f36', '-f ddd', '-i43', '-i eee', '-stg1', '-s ffff'
    ],
    'interval' => '99',
    'jmxdomain' => 'com.example.monitoring'
  )

  action :create
end

# | Apply All | Unique fields | Count | Enforce count |
# | --------- | ------------- | ----- | ------------- |
# | 0         | 1             | N     | 0             |
cq_osgi_config 'UGCCResourceProviderFactory' do
  factory_pid 'com.adobe.cq.social.datastore.as.impl.'\
    'UGCCResourceProviderFactory'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'version.id' => 'v1',
    'cache.on' => 'true',
    'cache.ttl' => '1000'
  )
  unique_fields ['version.id', 'cache.on']
  count 3

  action :create
end

# | Apply All | Unique fields | Count | Enforce count |
# | --------- | ------------- | ----- | ------------- |
# | 0         | 0             | N     | 0             |
cq_osgi_config 'com.day.cq.mcm.impl.MCMConfiguration' do
  factory_pid 'com.day.cq.mcm.impl.MCMConfiguration'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'experience.indirection' => [
      'geometrixx/components/newsletterpage',
      'mcm/components/newsletter/page'
    ],
    'touchpoint.indirection' => [
      'exampleGeometrixxAddedComp',
      'exampleMCMSuperTouchpoint'
    ],
    'extraProperty' => %w(a b c)
  )
  count 7

  action :create
end

# | Apply All | Unique fields | Count | Enforce count |
# | --------- | ------------- | ----- | ------------- |
# | 0         | 1             | 1     | 0             |
cq_osgi_config 'org.apache.sling.resource.inventory.impl.'\
  'ResourceInventoryPrinterFactory' do
  factory_pid 'org.apache.sling.resource.inventory.impl.'\
    'ResourceInventoryPrinterFactory'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties('felix.inventory.printer.name' => 'aaaaabbbbbcccccddddd')
  unique_fields ['felix.inventory.printer.name']

  action :create
end

# | Apply All | Unique fields | Count | Enforce count |
# | --------- | ------------- | ----- | ------------- |
# | 0         | 1             | N     | 1             |
cq_osgi_config 'Create 3 new instances of custom logger' do
  factory_pid 'org.apache.sling.commons.log.LogManager.factory.config'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'org.apache.sling.commons.log.level' => 'info',
    'org.apache.sling.commons.log.file' => 'logs/custom.log',
    'org.apache.sling.commons.log.pattern' =>
      '{0,date,dd.MM.yyyy HH:mm:ss.SSS} *{4}* [{2}] {3} {5}',
    'org.apache.sling.commons.log.names' => %w(com.example.myapp)
  )
  unique_fields ['org.apache.sling.commons.log.file']
  count 3

  action :create
end

cq_osgi_config 'Reduce to 2 instances of custom logger' do
  factory_pid 'org.apache.sling.commons.log.LogManager.factory.config'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'org.apache.sling.commons.log.level' => 'info',
    'org.apache.sling.commons.log.file' => 'logs/custom.log',
    'org.apache.sling.commons.log.pattern' =>
      '{0,date,dd.MM.yyyy HH:mm:ss.SSS} *{4}* [{2}] {3} {5}',
    'org.apache.sling.commons.log.names' => %w(com.example.myapp)
  )
  unique_fields ['org.apache.sling.commons.log.file']
  count 2
  enforce_count true

  action :create
end

# | Apply All | Unique fields | Count | Enforce count |
# | --------- | ------------- | ----- | ------------- |
# | 1         | 1             | 1     | 0             |
cq_osgi_config 'SyncDistributionAgentFactory' do
  factory_pid 'org.apache.sling.distribution.agent.impl.'\
    'SyncDistributionAgentFactory'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'name' => 'socialpubsync',
    'packageExporter.endpoints' => %w(http://localhost:8443/exporter),
    'packageImporter.endpoints' => %w(http://localhost:8443/importer),
    'pull.items' => '100'
  )
  append true
  unique_fields ['name']
  apply_all true

  action :create
end

cq_osgi_config 'Adobe Granite OCS Lifecycle' do
  factory_pid 'com.adobe.granite.ocs.core.internal.OCSLifeCycle'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'com.adobe.granite.ocs.lifecycle.name' => 'com/adobe/granite/ocs/deploy',
    'com.adobe.granite.ocs.lifecycle.phases' => %w(
      validate
      prepare
      bootstrap
      configure
      install
      test
      deploy
      uninstall
    )
  )
  unique_fields %w(com/adobe/granite/ocs/deploy)
  include_missing true

  action :create
end

# -----------------------------------------------------------------------------
# Factory configs (delete)
# -----------------------------------------------------------------------------

cq_osgi_config 'org.apache.sling.hc.core.impl.CompositeHealthCheck' do
  factory_pid 'org.apache.sling.hc.core.impl.CompositeHealthCheck'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'hc.name' => 'Security Checks',
  )
  unique_fields ['hc.name']

  action :delete
end

cq_osgi_config 'org.apache.sling.event.jobs.QueueConfiguration' do
  factory_pid 'org.apache.sling.event.jobs.QueueConfiguration'
  username node['cq']['author']['credentials']['login']
  password node['cq']['author']['credentials']['password']
  instance "http://localhost:#{node['cq']['author']['port']}"
  properties(
    'queue.name' => 'Granite Workflow Timeout Queue',
    'queue.topics' => ['com/adobe/granite/workflow/timeout/job'],
    'queue.type' => 'TOPIC_ROUND_ROBIN',
    'queue.maxparallel' => -1,
    'queue.retries' => 10,
    'queue.retrydelay' => 2000,
    'queue.priority' => 'MIN',
    'service.ranking' => 0
  )
  unique_fields ['queue.name']

  action :delete
end
