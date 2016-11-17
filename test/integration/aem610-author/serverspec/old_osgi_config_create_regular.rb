require_relative '../../../kitchen/data/spec_helper'

describe 'OSGi config '\
  'com.day.cq.dam.s7dam.common.S7damDamChangeEventListener' do
  it 'in total there were 2 HTTP requests' do
    expect(
      @osgi_config_helper.all_requests(
        'com.day.cq.dam.s7dam.common.S7damDamChangeEventListener'
      ).length
    ).to eq(2)
  end

  it 'has cq.dam.s7dam.damchangeeventlistener.enabled set to false' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.dam.s7dam.common.S7damDamChangeEventListener',
        'cq.dam.s7dam.damchangeeventlistener.enabled'
      )
    ).to eq(false)
  end
end

describe 'OSGi config '\
  'com.day.cq.dam.scene7.impl.Scene7ConfigurationEventListener' do
  it 'in total there was 1 HTTP request' do
    expect(
      @osgi_config_helper.all_requests(
        'com.day.cq.dam.scene7.impl.Scene7ConfigurationEventListener'
      ).length
    ).to eq(1)
  end

  it 'has cq.dam.scene7.configurationeventlistener.enabled set to true' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.dam.scene7.impl.Scene7ConfigurationEventListener',
        'cq.dam.scene7.configurationeventlistener.enabled'
      )
    ).to eq(true)
  end
end

describe 'OSGi com.day.cq.wcm.foundation.impl.AdaptiveImageComponentServlet' do
  it 'in total there were 2 HTTP requests' do
    expect(
      @osgi_config_helper.all_requests(
        'com.day.cq.wcm.foundation.impl.AdaptiveImageComponentServlet'
      ).length
    ).to eq(2)
  end

  it 'has adapt.supported.widths set to ["325","480","476","620","720"]' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.wcm.foundation.impl.AdaptiveImageComponentServlet',
        'adapt.supported.widths'
      )
    ).to eq(%w(325 476 480 620 720))
  end
end

describe 'OSGi com.adobe.cq.media.publishing.dps.impl.contentsync.'\
  'DPSPagesUpdateHandler' do
  it 'in total there was 1 HTTP request' do
    expect(
      @osgi_config_helper.all_requests(
        'com.adobe.cq.media.publishing.dps.impl.contentsync.'\
        'DPSPagesUpdateHandler'
      ).length
    ).to eq(1)
  end

  it 'cq.pagesupdatehandler.imageresourcetypes is set to ["foundation'\
    '/components/image"]' do
    expect(
      @osgi_config_helper.config_value(
        'com.adobe.cq.media.publishing.dps.impl.contentsync.'\
        'DPSPagesUpdateHandler',
        'cq.pagesupdatehandler.imageresourcetypes'
      )
    ).to eq(['foundation/components/image'])
  end
end

describe 'OSGi com.adobe.cq.media.publishing.dps.impl.contentsync.'\
  'DPSSubPagesUpdateHandler' do
  it 'in total there were 2 HTTP requests' do
    expect(
      @osgi_config_helper.all_requests(
        'com.adobe.cq.media.publishing.dps.impl.contentsync.'\
        'DPSSubPagesUpdateHandler'
      ).length
    ).to eq(2)
  end

  it 'cq.pagesupdatehandler.imageresourcetypes is set to '\
    '["foundation/components/image","test/append/value"]' do
    expect(
      @osgi_config_helper.config_value(
        'com.adobe.cq.media.publishing.dps.impl.contentsync.'\
        'DPSSubPagesUpdateHandler',
        'cq.pagesupdatehandler.imageresourcetypes'
      )
    ).to eq(['foundation/components/image', 'test/append/value'])
  end
end

describe 'OSGi com.day.cq.dam.scene7.impl.Scene7AssetMimeTypeServiceImpl' do
  it 'in total there were 2 HTTP requests' do
    expect(
      @osgi_config_helper.all_requests(
        'com.day.cq.dam.scene7.impl.Scene7AssetMimeTypeServiceImpl'
      ).length
    ).to eq(2)
  end

  it 'cq.dam.scene7.assetmimetypeservice.mapping is set to original value' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.dam.scene7.impl.Scene7AssetMimeTypeServiceImpl',
        'cq.dam.scene7.assetmimetypeservice.mapping'
      )
    ).to eq(
      [
        'Flash=image/s7flashtemplate',
        'Generic=image/s7asset',
        'Image.jpeg=image/jpeg',
        'Image=image/*',
        'Image=image/jpeg',
        'PDF=application/pdf',
        'Template=image/s7template',
        'Video.f4v=video/mp4',
        'Video.flv=video/x-flv',
        'Video.mp4=video/mp4',
        'Video=video/*'
      ]
    )
  end
end

describe 'OSGi com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl' do
  it 'in total there were 2 HTTP requests' do
    expect(
      @osgi_config_helper.all_requests(
        'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl'
      ).length
    ).to eq(2)
  end

  it 'scheduler.period is set to 5' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl',
        'scheduler.period'
      )
    ).to match(/^5$/)
  end

  it 'scheduler.concurrent is set to false' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl',
        'scheduler.concurrent'
      )
    ).to match(/^false$/)
  end

  it 'service.bad_link_tolerance_interval is set to 24' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl',
        'service.bad_link_tolerance_interval'
      )
    ).to eq(24)
  end

  it 'service.check_override_patterns is set to "^system/"' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl',
        'service.check_override_patterns'
      )
    ).to eq(['^system/'])
  end

  it 'service.cache_broken_internal_links is set to true' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl',
        'service.cache_broken_internal_links'
      )
    ).to eq(true)
  end

  it 'service.special_link_prefix is set to ["#","${","<!--","data:",'\
    '"javascript:","mailto:","rx:","z:"]"}"]' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl',
        'service.special_link_prefix'
      )
    ).to eq(
      ['#', '${', '<!--', 'data:', 'javascript:', 'mailto:', 'rx:', 'z:']
    )
  end

  it 'service.special_link_patterns is empty' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl',
        'service.special_link_patterns'
      )
    ).to match(/^$/)
  end
end

describe 'OSGi com.day.cq.dam.core.impl.servlet.HealthCheckServlet' do
  it 'in total there were 2 HTTP requests' do
    expect(
      @osgi_config_helper.all_requests(
        'com.day.cq.dam.core.impl.servlet.HealthCheckServlet'
      ).length
    ).to eq(2)
  end

  it 'sling.servlet.paths is set to /libs/dam/health_check' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.dam.core.impl.servlet.HealthCheckServlet',
        'sling.servlet.paths'
      )
    ).to match(%r{^/libs/dam/health_check$})
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

  it 'sling.servlet.extensions is set to json' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.dam.core.impl.servlet.HealthCheckServlet',
        'sling.servlet.extensions'
      )
    ).to match(/^json$/)
  end

  it 'cq.dam.sync.workflow.id is set to /some/path/to/model' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.dam.core.impl.servlet.HealthCheckServlet',
        'cq.dam.sync.workflow.id'
      )
    ).to match(%r{^/some/path/to/model$})
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
end

describe 'OSGi com.adobe.granite.queries.impl.explain.query.'\
  'ExplainQueryServlet' do
  it 'in total there was 1 HTTP request' do
    expect(
      @osgi_config_helper.all_requests(
        'com.adobe.granite.queries.impl.explain.query.ExplainQueryServlet'
      ).length
    ).to eq(1)
  end

  it 'has log.message-count-limit set to 100' do
    expect(
      @osgi_config_helper.config_value(
        'com.adobe.granite.queries.impl.explain.query.ExplainQueryServlet',
        'log.message-count-limit'
      )
    ).to match(/^100$/)
  end
end

describe 'OSGi org.apache.felix.eventadmin.impl.EventAdmin' do
  it 'in total there were 2 HTTP requests' do
    expect(
      @osgi_config_helper.all_requests(
        'org.apache.felix.eventadmin.impl.EventAdmin'
      ).length
    ).to eq(2)
  end

  it 'org.apache.felix.eventadmin.ThreadPoolSize is set to 20' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.felix.eventadmin.impl.EventAdmin',
        'org.apache.felix.eventadmin.ThreadPoolSize'
      )
    ).to match(/^20$/)
  end

  it 'org.apache.felix.eventadmin.Timeout is set to 5000' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.felix.eventadmin.impl.EventAdmin',
        'org.apache.felix.eventadmin.Timeout'
      )
    ).to match(/^5000$/)
  end

  it 'org.apache.felix.eventadmin.RequireTopic is set to true' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.felix.eventadmin.impl.EventAdmin',
        'org.apache.felix.eventadmin.RequireTopic'
      )
    ).to match(/^true/)
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
end

describe 'OSGi org.apache.sling.engine.impl.SlingMainServlet' do
  it 'in total there was 1 HTTP request' do
    expect(
      @osgi_config_helper.all_requests(
        'org.apache.sling.engine.impl.SlingMainServlet'
      ).length
    ).to eq(1)
  end

  it 'sling.max.calls is set to 1500' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.sling.engine.impl.SlingMainServlet',
        'sling.max.calls'
      )
    ).to eq(1500)
  end

  it 'sling.max.inclusions is set to 50' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.sling.engine.impl.SlingMainServlet',
        'sling.max.inclusions'
      )
    ).to eq('50')
  end

  it 'sling.trace.allow is set to false' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.sling.engine.impl.SlingMainServlet',
        'sling.trace.allow'
      )
    ).to eq('false')
  end

  it 'sling.filter.compat.mode is set to false' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.sling.engine.impl.SlingMainServlet',
        'sling.filter.compat.mode'
      )
    ).to eq('false')
  end

  it 'sling.max.record.requests is set to 20' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.sling.engine.impl.SlingMainServlet',
        'sling.max.record.requests'
      )
    ).to eq('20')
  end

  it 'sling.store.pattern.requests is set to []' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.sling.engine.impl.SlingMainServlet',
        'sling.store.pattern.requests'
      )
    ).to eq([])
  end
end
