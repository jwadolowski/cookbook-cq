require_relative '../../../kitchen/data/spec_helper'

describe 'com.day.cq.dam.s7dam.common.S7damDamChangeEventListener' do
  it 'cq.dam.s7dam.damchangeeventlistener.enabled is set to false' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.dam.s7dam.common.S7damDamChangeEventListener',
        'cq.dam.s7dam.damchangeeventlistener.enabled'
      )
    ).to eq(false)
  end

  it 'cq.dam.s7dam.damchangeeventlistener.enabled is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'com.day.cq.dam.s7dam.common.S7damDamChangeEventListener',
        'cq.dam.s7dam.damchangeeventlistener.enabled'
      )
    ).to eq(true)
  end
end

describe 'com.day.cq.dam.scene7.impl.Scene7ConfigurationEventListener' do
  it 'cq.dam.scene7.configurationeventlistener.enabled is set to false' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.dam.scene7.impl.Scene7ConfigurationEventListener',
        'cq.dam.scene7.configurationeventlistener.enabled'
      )
    ).to eq(false)
  end

  it 'cq.dam.scene7.configurationeventlistener.enabled is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'com.day.cq.dam.scene7.impl.Scene7ConfigurationEventListener',
        'cq.dam.scene7.configurationeventlistener.enabled'
      )
    ).to eq(true)
  end
end

describe 'org.apache.sling.engine.impl.SlingMainServlet' do
  it 'sling.max.calls is set to 1500' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.sling.engine.impl.SlingMainServlet',
        'sling.max.calls'
      )
    ).to eq(1500)
  end

  it 'sling.max.calls is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'org.apache.sling.engine.impl.SlingMainServlet',
        'sling.max.calls'
      )
    ).to eq(true)
  end

  it 'sling.max.inclusions is set to 50' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.sling.engine.impl.SlingMainServlet',
        'sling.max.inclusions'
      )
    ).to eq(50)
  end

  it 'sling.max.inclusions is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'org.apache.sling.engine.impl.SlingMainServlet',
        'sling.max.inclusions'
      )
    ).to eq(true)
  end

  it 'sling.trace.allow is set to false' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.sling.engine.impl.SlingMainServlet',
        'sling.trace.allow'
      )
    ).to eq(false)
  end

  it 'sling.trace.allow is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'org.apache.sling.engine.impl.SlingMainServlet',
        'sling.trace.allow'
      )
    ).to eq(true)
  end

  it 'sling.filter.compat.mode is set to false' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.sling.engine.impl.SlingMainServlet',
        'sling.filter.compat.mode'
      )
    ).to eq(false)
  end

  it 'sling.filter.compat.mode is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'org.apache.sling.engine.impl.SlingMainServlet',
        'sling.filter.compat.mode'
      )
    ).to eq(true)
  end

  it 'sling.max.record.requests is set to 60' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.sling.engine.impl.SlingMainServlet',
        'sling.max.record.requests'
      )
    ).to eq(60)
  end

  it 'sling.max.record.requests is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'org.apache.sling.engine.impl.SlingMainServlet',
        'sling.max.record.requests'
      )
    ).to eq(true)
  end

  it 'sling.store.pattern.requests is set to an empty array' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.sling.engine.impl.SlingMainServlet',
        'sling.store.pattern.requests'
      )
    ).to eq(%w())
  end

  it 'sling.store.pattern.requests is not explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'org.apache.sling.engine.impl.SlingMainServlet',
        'sling.store.pattern.requests'
      )
    ).to eq(false)
  end

  it 'sling.serverinfo is set to an empty string' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.sling.engine.impl.SlingMainServlet',
        'sling.serverinfo'
      )
    ).to eq("")
  end

  it 'sling.serverinfo is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'org.apache.sling.engine.impl.SlingMainServlet',
        'sling.serverinfo'
      )
    ).to eq(true)
  end

  it 'sling.additional.response.headers is set to '\
    '[X-Content-Type-Options=nosniff]' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.sling.engine.impl.SlingMainServlet',
        'sling.additional.response.headers'
      )
    ).to eq(%w(X-Content-Type-Options=nosniff))
  end

  it 'sling.additional.response.headers is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'org.apache.sling.engine.impl.SlingMainServlet',
        'sling.additional.response.headers'
      )
    ).to eq(true)
  end
end

describe 'com.day.cq.wcm.foundation.impl.AdaptiveImageComponentServlet' do
  it 'has adapt.supported.widths set to [1080, 325, 480, 476, 620, 720]' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.wcm.foundation.impl.AdaptiveImageComponentServlet',
        'adapt.supported.widths'
      )
    ).to eq(%w(1080 325 476 480 620 720))
  end

  it 'adapt.supported.widths is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'com.day.cq.wcm.foundation.impl.AdaptiveImageComponentServlet',
        'adapt.supported.widths'
      )
    ).to eq(true)
  end
end

describe 'com.adobe.cq.media.publishing.dps.impl.contentsync.'\
  'DPSPagesUpdateHandler' do
  it 'cq.pagesupdatehandler.imageresourcetypes is set to '\
    '[foundation/components/image, foundation/components/test]' do
    expect(
      @osgi_config_helper.config_value(
        'com.adobe.cq.media.publishing.dps.impl.contentsync.'\
        'DPSPagesUpdateHandler',
        'cq.pagesupdatehandler.imageresourcetypes'
      )
    ).to eq(%w(foundation/components/image foundation/components/test))
  end

  it 'cq.pagesupdatehandler.imageresourcetypes is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'com.adobe.cq.media.publishing.dps.impl.contentsync.'\
        'DPSPagesUpdateHandler',
        'cq.pagesupdatehandler.imageresourcetypes'
      )
    ).to eq(true)
  end
end

describe 'com.adobe.cq.media.publishing.dps.impl.contentsync.'\
  'DPSSubPagesUpdateHandler' do
  it 'cq.pagesupdatehandler.imageresourcetypes is set to '\
    '[foundation/components/image, test/append/value]' do
    expect(
      @osgi_config_helper.config_value(
        'com.adobe.cq.media.publishing.dps.impl.contentsync.'\
        'DPSSubPagesUpdateHandler',
        'cq.pagesupdatehandler.imageresourcetypes'
      )
    ).to eq(%w(foundation/components/image test/append/value))
  end

  it 'cq.pagesupdatehandler.imageresourcetypes is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'com.adobe.cq.media.publishing.dps.impl.contentsync.'\
        'DPSSubPagesUpdateHandler',
        'cq.pagesupdatehandler.imageresourcetypes'
      )
    ).to eq(true)
  end
end

describe 'com.day.cq.dam.scene7.impl.Scene7AssetMimeTypeServiceImpl' do
  it 'cq.dam.scene7.assetmimetypeservice.mapping contains Image=image/jpeg '\
    'and Image=image/png' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.dam.scene7.impl.Scene7AssetMimeTypeServiceImpl',
        'cq.dam.scene7.assetmimetypeservice.mapping'
      )
    ).to eq(
      %w(
        Flash=image/s7flashtemplate
        Generic=image/s7asset
        Image.jpeg=image/jpeg
        Image=image/*
        Image=image/jpeg
        Image=image/png
        PDF=application/pdf
        Template=image/s7template
        Video.f4v=video/mp4
        Video.flv=video/x-flv
        Video.mp4=video/mp4
        Video=video/*
      )
    )
  end

  it 'cq.dam.scene7.assetmimetypeservice.mapping is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'com.day.cq.dam.scene7.impl.Scene7AssetMimeTypeServiceImpl',
        'cq.dam.scene7.assetmimetypeservice.mapping'
      )
    ).to eq(true)
  end
end

describe 'OSGi com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl' do
  it 'scheduler.period is set to 5' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl',
        'scheduler.period'
      )
    ).to eq("5")
  end

  it 'scheduler.period is not explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl',
        'scheduler.period'
      )
    ).to eq(false)
  end

  it 'scheduler.concurrent is set to false' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl',
        'scheduler.concurrent'
      )
    ).to eq("false")
  end

  it 'scheduler.concurrent is not explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl',
        'scheduler.concurrent'
      )
    ).to eq(false)
  end

  it 'service.bad_link_tolerance_interval is set to 24' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl',
        'service.bad_link_tolerance_interval'
      )
    ).to eq(24)
  end

  it 'service.bad_link_tolerance_interval is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl',
        'service.bad_link_tolerance_interval'
      )
    ).to eq(true)
  end

  it 'service.check_override_patterns is set to [^qwerty/, ^system/]' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl',
        'service.check_override_patterns'
      )
    ).to eq(%w(^qwerty/ ^system/))
  end

  it 'service.check_override_patterns is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl',
        'service.check_override_patterns'
      )
    ).to eq(true)
  end

  it 'service.cache_broken_internal_links is set to true' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl',
        'service.cache_broken_internal_links'
      )
    ).to eq(true)
  end

  it 'service.cache_broken_internal_links is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl',
        'service.cache_broken_internal_links'
      )
    ).to eq(true)
  end

  it 'service.special_link_prefix is set to custom array' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl',
        'service.special_link_prefix'
      )
    ).to eq(
      ['#', '${', '<!--', 'data:', 'javascript:', 'mailto:', 'rx:', 'z:']
    )
  end

  it 'service.special_link_prefix is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl',
        'service.special_link_prefix'
      )
    ).to eq(true)
  end

  it 'service.special_link_patterns is empty' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl',
        'service.special_link_patterns'
      )
    ).to eq("")
  end

  it 'service.special_link_patterns is not explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl',
        'service.special_link_patterns'
      )
    ).to eq(false)
  end
end

describe 'com.day.cq.dam.core.impl.servlet.HealthCheckServlet' do
  it 'sling.servlet.paths is set to /libs/dam/health_check' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.dam.core.impl.servlet.HealthCheckServlet',
        'sling.servlet.paths'
      )
    ).to match(%r{^/libs/dam/health_check$})
  end

  it 'sling.servlet.paths is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'com.day.cq.dam.core.impl.servlet.HealthCheckServlet',
        'sling.servlet.paths'
      )
    ).to eq(true)
  end

  it 'sling.servlet.methods is set to ["GET", "POST", "CUSTOM", "-stop",'\
    ' "-i NJECT"]' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.dam.core.impl.servlet.HealthCheckServlet',
        'sling.servlet.methods'
      )
    ).to eq(['-i NJECT', '-stop', 'CUSTOM', 'GET', 'POST'])
  end

  it 'sling.servlet.methods is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'com.day.cq.dam.core.impl.servlet.HealthCheckServlet',
        'sling.servlet.methods'
      )
    ).to eq(true)
  end

  it 'sling.servlet.extensions is set to json' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.dam.core.impl.servlet.HealthCheckServlet',
        'sling.servlet.extensions'
      )
    ).to match(/^json$/)
  end

  it 'sling.servlet.extensions is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'com.day.cq.dam.core.impl.servlet.HealthCheckServlet',
        'sling.servlet.extensions'
      )
    ).to eq(true)
  end

  it 'cq.dam.sync.workflow.id is set to /some/path/to/model' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.dam.core.impl.servlet.HealthCheckServlet',
        'cq.dam.sync.workflow.id'
      )
    ).to match(%r{^/some/path/to/model$})
  end

  it 'cq.dam.sync.workflow.id is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'com.day.cq.dam.core.impl.servlet.HealthCheckServlet',
        'cq.dam.sync.workflow.id'
      )
    ).to eq(true)
  end

  it 'cq.dam.sync.folder.types is set to valid array' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.dam.core.impl.servlet.HealthCheckServlet',
        'cq.dam.sync.folder.types'
      )
    ).to eq(
      ['-i', '-i X', '-iX', '-p', '-p Y', '-pY', '-u', '-u Z', '-uZ', 'sth']
    )
  end

  it 'cq.dam.sync.folder.types is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'com.day.cq.dam.core.impl.servlet.HealthCheckServlet',
        'cq.dam.sync.folder.types'
      )
    ).to eq(true)
  end
end

describe 'org.apache.felix.eventadmin.impl.EventAdmin' do
  it 'org.apache.felix.eventadmin.ThreadPoolSize is set to 20' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.felix.eventadmin.impl.EventAdmin',
        'org.apache.felix.eventadmin.ThreadPoolSize'
      )
    ).to eq(20)
  end

  it 'org.apache.felix.eventadmin.ThreadPoolSize is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'org.apache.felix.eventadmin.impl.EventAdmin',
        'org.apache.felix.eventadmin.ThreadPoolSize'
      )
    ).to eq(true)
  end

  it 'org.apache.felix.eventadmin.AsyncToSyncThreadRatio is set to 0.5' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.felix.eventadmin.impl.EventAdmin',
        'org.apache.felix.eventadmin.AsyncToSyncThreadRatio'
      )
    ).to eq(0.5)
  end

  it 'org.apache.felix.eventadmin.AsyncToSyncThreadRatio is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'org.apache.felix.eventadmin.impl.EventAdmin',
        'org.apache.felix.eventadmin.AsyncToSyncThreadRatio'
      )
    ).to eq(true)
  end

  it 'org.apache.felix.eventadmin.Timeout is set to 5000' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.felix.eventadmin.impl.EventAdmin',
        'org.apache.felix.eventadmin.Timeout'
      )
    ).to eq(5000)
  end

  it 'org.apache.felix.eventadmin.Timeout is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'org.apache.felix.eventadmin.impl.EventAdmin',
        'org.apache.felix.eventadmin.Timeout'
      )
    ).to eq(true)
  end

  it 'org.apache.felix.eventadmin.RequireTopic is set to true' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.felix.eventadmin.impl.EventAdmin',
        'org.apache.felix.eventadmin.RequireTopic'
      )
    ).to eq(true)
  end

  it 'org.apache.felix.eventadmin.RequireTopic is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'org.apache.felix.eventadmin.impl.EventAdmin',
        'org.apache.felix.eventadmin.RequireTopic'
      )
    ).to eq(true)
  end

  it 'org.apache.felix.eventadmin.IgnoreTimeout is set to '\
    '["com.adobe*", "com.day*", "com.example*", "org.apache.felix*", '\
    '"org.apache.sling*"]' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.felix.eventadmin.impl.EventAdmin',
        'org.apache.felix.eventadmin.IgnoreTimeout'
      )
    ).to eq(
      [
        'com.adobe*',
        'com.day*',
        'com.example*',
        'org.apache.felix*',
        'org.apache.sling*'
      ]
    )
  end

  it 'org.apache.felix.eventadmin.IgnoreTimeout is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'org.apache.felix.eventadmin.impl.EventAdmin',
        'org.apache.felix.eventadmin.IgnoreTimeout'
      )
    ).to eq(true)
  end

  it 'org.apache.felix.eventadmin.IgnoreTopic is set an empty array' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.felix.eventadmin.impl.EventAdmin',
        'org.apache.felix.eventadmin.IgnoreTopic'
      )
    ).to eq(%w())
  end

  it 'org.apache.felix.eventadmin.IgnoreTopic is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'org.apache.felix.eventadmin.impl.EventAdmin',
        'org.apache.felix.eventadmin.IgnoreTopic'
      )
    ).to eq(false)
  end
end

describe 'com.adobe.granite.queries.impl.explain.query.ExplainQueryServlet' do
  it 'log.logger-names is set to [org.apache.jackrabbit.oak.plugins.index, '\
    'org.apache.jackrabbit.oak.query]' do
    expect(
      @osgi_config_helper.config_value(
        'com.adobe.granite.queries.impl.explain.query.ExplainQueryServlet',
        'log.logger-names'
      )
    ).to eq(
      %w(
        org.apache.jackrabbit.oak.plugins.index
        org.apache.jackrabbit.oak.query
      )
    )
  end

  it 'log.logger-names is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'com.adobe.granite.queries.impl.explain.query.ExplainQueryServlet',
        'log.logger-names'
      )
    ).to eq(true)
  end

  it 'log.pattern is set to %msg%n' do
    expect(
      @osgi_config_helper.config_value(
        'com.adobe.granite.queries.impl.explain.query.ExplainQueryServlet',
        'log.pattern'
      )
    ).to eq('%msg%n')
  end

  it 'log.pattern is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'com.adobe.granite.queries.impl.explain.query.ExplainQueryServlet',
        'log.pattern'
      )
    ).to eq(true)
  end

  it 'log.message-count-limit is set to 150' do
    expect(
      @osgi_config_helper.config_value(
        'com.adobe.granite.queries.impl.explain.query.ExplainQueryServlet',
        'log.message-count-limit'
      )
    ).to eq(150)
  end

  it 'log.message-count-limit is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'com.adobe.granite.queries.impl.explain.query.ExplainQueryServlet',
        'log.message-count-limit'
      )
    ).to eq(true)
  end

  it 'logging.enabled is set to false' do
    expect(
      @osgi_config_helper.config_value(
        'com.adobe.granite.queries.impl.explain.query.ExplainQueryServlet',
        'logging.enabled'
      )
    ).to eq(false)
  end

  it 'logging.enabled is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'com.adobe.granite.queries.impl.explain.query.ExplainQueryServlet',
        'logging.enabled'
      )
    ).to eq(true)
  end
end

describe 'com.day.cq.wcm.foundation.forms.impl.MailServlet' do
  it 'resource.whitelist is set to [/content, /home, /test1, /test2]' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.wcm.foundation.forms.impl.MailServlet',
        'resource.whitelist'
      )
    ).to eq(%w(/content /home /test1 /test2))
  end

  it 'resource.whitelist is explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'com.day.cq.wcm.foundation.forms.impl.MailServlet',
        'resource.whitelist'
      )
    ).to eq(true)
  end
end

describe 'com.adobe.cq.wcm.launches.impl.LaunchesEventHandler' do
  it 'event.filter is set to (!(event.application=*))' do
    expect(
      @osgi_config_helper.config_value(
        'com.adobe.cq.wcm.launches.impl.LaunchesEventHandler',
        'event.filter'
      )
    ).to eq('(!(event.application=*))')
  end

  it 'event.filter is not explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'com.adobe.cq.wcm.launches.impl.LaunchesEventHandler',
        'event.filter'
      )
    ).to eq(false)
  end

  it 'launches.eventhandler.threadpool.maxsize is set to 5' do
    expect(
      @osgi_config_helper.config_value(
        'com.adobe.cq.wcm.launches.impl.LaunchesEventHandler',
        'launches.eventhandler.threadpool.maxsize'
      )
    ).to eq('5')
  end

  it 'launches.eventhandler.threadpool.maxsize is not explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'com.adobe.cq.wcm.launches.impl.LaunchesEventHandler',
        'launches.eventhandler.threadpool.maxsize'
      )
    ).to eq(false)
  end

  it 'launches.eventhandler.threadpool.priority is set to MIN' do
    expect(
      @osgi_config_helper.config_value(
        'com.adobe.cq.wcm.launches.impl.LaunchesEventHandler',
        'launches.eventhandler.threadpool.priority'
      )
    ).to eq('MIN')
  end

  it 'launches.eventhandler.threadpool.priority is not explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'com.adobe.cq.wcm.launches.impl.LaunchesEventHandler',
        'launches.eventhandler.threadpool.priority'
      )
    ).to eq(false)
  end

  it 'launches.eventhandler.updatelastmodification is set to false' do
    expect(
      @osgi_config_helper.config_value(
        'com.adobe.cq.wcm.launches.impl.LaunchesEventHandler',
        'launches.eventhandler.updatelastmodification'
      )
    ).to eq('false')
  end

  it 'launches.eventhandler.updatelastmodification is not explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'com.adobe.cq.wcm.launches.impl.LaunchesEventHandler',
        'launches.eventhandler.updatelastmodification'
      )
    ).to eq(false)
  end
end

describe 'com.adobe.cq.commerce.impl.promotion.PromotionManagerImpl' do
  it 'cq.commerce.promotion.root is set to /content/campaigns' do
    expect(
      @osgi_config_helper.config_value(
        'com.adobe.cq.commerce.impl.promotion.PromotionManagerImpl',
        'cq.commerce.promotion.root'
      )
    ).to eq('/content/campaigns')
  end

  it 'cq.commerce.promotion.root is not explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'com.adobe.cq.commerce.impl.promotion.PromotionManagerImpl',
        'cq.commerce.promotion.root'
      )
    ).to eq(false)
  end
end

describe 'com.adobe.granite.auth.oauth.impl.TwitterProviderImpl' do
  it 'oauth.provider.id is set to twitter' do
    expect(
      @osgi_config_helper.config_value(
        'com.adobe.granite.auth.oauth.impl.TwitterProviderImpl',
        'oauth.provider.id'
      )
    ).to eq('twitter')
  end

  it 'oauth.provider.id is not explicitly set' do
    expect(
      @osgi_config_helper.config_is_set(
        'com.adobe.granite.auth.oauth.impl.TwitterProviderImpl',
        'oauth.provider.id'
      )
    ).to eq(false)
  end
end
