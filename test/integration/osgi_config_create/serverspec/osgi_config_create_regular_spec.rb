require_relative '../../../kitchen/data/spec_helper'

describe 'OSGi config not.existing.config.create.1k1v' do
  it 'there was NO attempts to create it' do
    expect(
      @osgi_config_helper.regular_update_requests(
        'not.existing.config.create.1k1v'
      ).length
    ).to eq(0)
  end

  it 'does NOT exist' do
    expect(
      @config_list.include?('not.existing.config.create.1k1v')
    ).to be false
  end

  it 'in total there was 0 HTTP requests' do
    expect(
      @osgi_config_helper.all_requests(
        'not.existing.config.create.1k1v'
      ).length
    ).to eq(0)
  end
end

describe 'OSGi config '\
  'com.day.cq.dam.s7dam.common.S7damDamChangeEventListener' do
  it 'there was single READ request' do
    expect(
      @osgi_config_helper.read_requests(
        'com.day.cq.dam.s7dam.common.S7damDamChangeEventListener'
      ).length
    ).to eq(1)
  end

  it 'there was single UPDATE request' do
    expect(
      @osgi_config_helper.regular_update_requests(
        'com.day.cq.dam.s7dam.common.S7damDamChangeEventListener'
      ).length
    ).to eq(1)
  end

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
    ).to match(/^false\n$/)
  end
end

describe 'OSGi config '\
  'com.day.cq.dam.scene7.impl.Scene7ConfigurationEventListener' do
  it 'there was single READ request' do
    expect(
      @osgi_config_helper.read_requests(
        'com.day.cq.dam.scene7.impl.Scene7ConfigurationEventListener'
      ).length
    ).to eq(1)
  end

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
    ).to match(/^true\n$/)
  end
end

describe 'OSGi config not.existing.config.create.1kNv' do
  it 'there was NO attempts to create it' do
    expect(
      @osgi_config_helper.regular_update_requests(
        'not.existing.config.create.1kNv'
      ).length
    ).to eq(0)
  end

  it 'does NOT exist' do
    expect(
      @config_list.include?('not.existing.config.create.1kNv')
    ).to be false
  end

  it 'in total there was 0 HTTP requests' do
    expect(
      @osgi_config_helper.all_requests(
        'not.existing.config.create.1kNv'
      ).length
    ).to eq(0)
  end
end

describe 'OSGi com.day.cq.wcm.foundation.impl.AdaptiveImageComponentServlet' do
  it 'there was single READ request' do
    expect(
      @osgi_config_helper.read_requests(
        'com.day.cq.wcm.foundation.impl.AdaptiveImageComponentServlet'
      ).length
    ).to eq(1)
  end

  it 'there was single UPDATE request' do
    expect(
      @osgi_config_helper.regular_update_requests(
        'com.day.cq.wcm.foundation.impl.AdaptiveImageComponentServlet'
      ).length
    ).to eq(1)
  end

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
    ).to match(/^\["325","476","480","620","720"\]\n$/)
  end
end

describe 'OSGi com.adobe.cq.media.publishing.dps.impl.contentsync.'\
  'DPSPagesUpdateHandler' do
  it 'there was single READ request' do
    expect(
      @osgi_config_helper.read_requests(
        'com.adobe.cq.media.publishing.dps.impl.contentsync.'\
        'DPSPagesUpdateHandler'
      ).length
    ).to eq(1)
  end

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
    ).to match(%r{^\["foundation/components/image"\]\n$})
  end
end

describe 'OSGi com.adobe.cq.media.publishing.dps.impl.contentsync.'\
  'DPSSubPagesUpdateHandler' do
  it 'there was single READ request' do
    expect(
      @osgi_config_helper.read_requests(
        'com.adobe.cq.media.publishing.dps.impl.contentsync.'\
        'DPSSubPagesUpdateHandler'
      ).length
    ).to eq(1)
  end

  it 'there was single UPDATE request' do
    expect(
      @osgi_config_helper.regular_update_requests(
        'com.adobe.cq.media.publishing.dps.impl.contentsync.'\
        'DPSSubPagesUpdateHandler'
      ).length
    ).to eq(1)
  end

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
    ).to match(
      %r{^\["foundation/components/image","test/append/value"\]\n$}
    )
  end
end

describe 'OSGi com.day.cq.dam.scene7.impl.Scene7AssetMimeTypeServiceImpl' do
  it 'there was single READ request' do
    expect(
      @osgi_config_helper.read_requests(
        'com.day.cq.dam.scene7.impl.Scene7AssetMimeTypeServiceImpl'
      ).length
    ).to eq(1)
  end

  it 'in total there was 1 HTTP request' do
    expect(
      @osgi_config_helper.all_requests(
        'com.day.cq.dam.scene7.impl.Scene7AssetMimeTypeServiceImpl'
      ).length
    ).to eq(1)
  end

  it 'cq.dam.scene7.assetmimetypeservice.mapping is set to original value' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.dam.scene7.impl.Scene7AssetMimeTypeServiceImpl',
        'cq.dam.scene7.assetmimetypeservice.mapping'
      )
    ).to match(%r{^\["Generic=image/s7asset",
               "Template=image/s7template",
               "Flash=image/s7flashtemplate",
               "Image=image/jpeg",
               "Video=video/\*",
               "Video\.mp4=video/mp4",
               "Video\.f4v=video/mp4",
               "Video\.flv=video/x-flv"\]\n$}x)
  end
end

describe 'OSGi not.existing.config.create.NkNv' do
  it 'there was NO attempts to read/modify it' do
    expect(
      @osgi_config_helper.regular_update_requests(
        'not.existing.config.create.NkNv'
      ).length
    ).to eq(0)
  end

  it 'does NOT exist' do
    expect(
      @config_list.include?('not.existing.config.create.NkNv')
    ).to be false
  end

  it 'in total there was 0 HTTP requests' do
    expect(
      @osgi_config_helper.all_requests(
        'not.existing.config.create.NkNv'
      ).length
    ).to eq(0)
  end
end

describe 'OSGi com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl' do
  it 'there was single READ request' do
    expect(
      @osgi_config_helper.read_requests(
        'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl'
      ).length
    ).to eq(1)
  end

  it 'there was single UPDATE request' do
    expect(
      @osgi_config_helper.regular_update_requests(
        'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl'
      ).length
    ).to eq(1)
  end

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
    ).to match(/^5\n$/)
  end

  it 'scheduler.concurrent is set to false' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl',
        'scheduler.concurrent'
      )
    ).to match(/^false\n$/)
  end

  it 'service.bad_link_tolerance_interval is set to 24' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl',
        'service.bad_link_tolerance_interval'
      )
    ).to match(/^24\n$/)
  end

  it 'service.check_override_patterns is set to "^system/"' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl',
        'service.check_override_patterns'
      )
    ).to match(/^\[\"\^system\/\"\]\n$/)
  end

  it 'service.cache_broken_internal_links is set to true' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl',
        'service.cache_broken_internal_links'
      )
    ).to match(/^true\n$/)
  end

  it 'service.special_link_prefix is set to ["#","${","<!--","data:",'\
    '"javascript:","mailto:","rx:","z:"]"}"]' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl',
        'service.special_link_prefix'
      )
    ).to match(
      /^\["#","\${","<!--","data:","javascript:","mailto:","rx:","z:"\]\n$/
    )
  end

  it 'service.special_link_patterns is empty' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.rewriter.linkchecker.impl.LinkCheckerImpl',
        'service.special_link_patterns'
      )
    ).to match(/^\n$/)
  end
end

describe 'OSGi com.adobe.mac.core.impl.DAMVolumeChecker' do
  it 'there was single READ request' do
    expect(
      @osgi_config_helper.read_requests(
        'com.adobe.mac.core.impl.DAMVolumeChecker'
      ).length
    ).to eq(1)
  end

  it 'in total there was 1 HTTP request' do
    expect(
      @osgi_config_helper.all_requests(
        'com.adobe.mac.core.impl.DAMVolumeChecker'
      ).length
    ).to eq(1)
  end

  it 'scheduler.expression is set to "0 0 0 * * ?"' do
    expect(
      @osgi_config_helper.config_value(
        'com.adobe.mac.core.impl.DAMVolumeChecker',
        'scheduler.expression'
      )
    ).to match(/^0\ 0\ 0\ \*\ \*\ \?\n$/)
  end

  it 'damRootPath is set to /content/dam/mac/' do
    expect(
      @osgi_config_helper.config_value(
        'com.adobe.mac.core.impl.DAMVolumeChecker',
        'damRootPath'
      )
    ).to match(%r{^/content/dam/mac/\n$})
  end

  it 'sizeThreshold is set to 500' do
    expect(
      @osgi_config_helper.config_value(
        'com.adobe.mac.core.impl.DAMVolumeChecker',
        'sizeThreshold'
      )
    ).to match(/^500\n$/)
  end

  it 'countThreshold is set to 1000' do
    expect(
      @osgi_config_helper.config_value(
        'com.adobe.mac.core.impl.DAMVolumeChecker',
        'countThreshold'
      )
    ).to match(/^1000\n$/)
  end

  it 'recipients is set to []' do
    expect(
      @osgi_config_helper.config_value(
        'com.adobe.mac.core.impl.DAMVolumeChecker',
        'recipients'
      )
    ).to match(/^\[\]\n$/)
  end
end

describe 'OSGi org.apache.felix.eventadmin.impl.EventAdmin' do
  it 'there was single READ request' do
    expect(
      @osgi_config_helper.read_requests(
        'org.apache.felix.eventadmin.impl.EventAdmin'
      ).length
    ).to eq(1)
  end

  it 'there was single UPDATE request' do
    expect(
      @osgi_config_helper.regular_update_requests(
        'org.apache.felix.eventadmin.impl.EventAdmin'
      ).length
    ).to eq(1)
  end

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
    ).to match(/^20\n$/)
  end

  it 'org.apache.felix.eventadmin.Timeout is set to 5000' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.felix.eventadmin.impl.EventAdmin',
        'org.apache.felix.eventadmin.Timeout'
      )
    ).to match(/^5000\n$/)
  end

  it 'org.apache.felix.eventadmin.RequireTopic is set to true' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.felix.eventadmin.impl.EventAdmin',
        'org.apache.felix.eventadmin.RequireTopic'
      )
    ).to match(/^true\n$/)
  end

  it 'org.apache.felix.eventadmin.IgnoreTimeout is set to '\
    '["com.adobe*", "com.day*", "com.example*", "org.apache.felix*", '\
    '"org.apache.sling*"]' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.felix.eventadmin.impl.EventAdmin',
        'org.apache.felix.eventadmin.IgnoreTimeout'
      )
    ).to match(
      %r{
      ^\["com\.adobe\*",
      "com\.day\*",
      "com\.example\*",
      "org\.apache.felix\*",
      "org\.apache.sling\*"
      \]\n$}x
    )
  end
end

describe 'OSGi org.apache.sling.engine.impl.SlingMainServlet' do
  it 'there was single READ request' do
    expect(
      @osgi_config_helper.read_requests(
        'org.apache.sling.engine.impl.SlingMainServlet'
      ).length
    ).to eq(1)
  end

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
    ).to match(/^1500\n$/)
  end

  it 'sling.max.inclusions is set to 50' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.sling.engine.impl.SlingMainServlet',
        'sling.max.inclusions'
      )
    ).to match(/^50\n$/)
  end

  it 'sling.trace.allow is set to false' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.sling.engine.impl.SlingMainServlet',
        'sling.trace.allow'
      )
    ).to match(/^false\n$/)
  end

  it 'sling.filter.compat.mode is set to false' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.sling.engine.impl.SlingMainServlet',
        'sling.filter.compat.mode'
      )
    ).to match(/^false\n$/)
  end

  it 'sling.max.record.requests is set to 20' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.sling.engine.impl.SlingMainServlet',
        'sling.max.record.requests'
      )
    ).to match(/^20\n$/)
  end

  it 'sling.store.pattern.requests is set to []' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.sling.engine.impl.SlingMainServlet',
        'sling.store.pattern.requests'
      )
    ).to match(/^\[\]\n$/)
  end

  it 'sling.default.parameter.encoding is empty' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.sling.engine.impl.SlingMainServlet',
        'sling.default.parameter.encoding'
      )
    ).to match(/^\n$/)
  end
end
