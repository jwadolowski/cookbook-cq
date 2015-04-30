require_relative '../../../kitchen/data/spec_helper'

describe 'OSGi config not.existing.config.create.1k1v' do
  it 'there was NO attempts to create it' do
    expect(
      @osgi_config_helper.log_entries(
        'not.existing.config.create.1k1v'
      ).length
    ).to eq(0)
  end

  it 'does NOT exists' do
    expect(
      @config_list.include?('not.existing.config.create.1k1v')
    ).to be false
  end
end

describe 'OSGi config '\
  'com.day.cq.dam.s7dam.common.S7damDamChangeEventListener' do

  # Two log entries - first one to get values, second to modify them
  it 'there were 2 requests (1st to check values, 2nd to modify them)' do
    expect(
      @osgi_config_helper.log_entries(
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
    ).to match(/^false$/)
  end

end

describe 'OSGi config '\
  'com.day.cq.dam.scene7.impl.Scene7ConfigurationEventListener' do

  it 'there was a single HTTP check to get current values' do
    expect(
      @osgi_config_helper.log_entries(
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
    ).to match(/^true$/)
  end
end

describe 'OSGi config not.existing.config.create.1kNv' do
  it 'there was NO attempts to create it' do
    expect(
      @osgi_config_helper.log_entries(
        'not.existing.config.create.1kNv'
      ).length
    ).to eq(0)
  end

  it 'does NOT exists' do
    expect(
      @config_list.include?('not.existing.config.create.1kNv')
    ).to be false
  end
end

describe 'OSGi com.day.cq.wcm.foundation.impl.AdaptiveImageComponentServlet' do
  it 'there were 2 HTTP requests' do
    expect(
      @osgi_config_helper.log_entries(
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
    ).to match(/\["325","476","480","620","720"\]/)
  end
end

describe 'OSGi com.adobe.cq.media.publishing.dps.impl.contentsync.'\
  'DPSPagesUpdateHandler' do
  it 'there was just a single HTTP request to check current values' do
    expect(
      @osgi_config_helper.log_entries(
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
    ).to match(/\["foundation\/components\/image"\]/)
  end
end

describe 'OSGi com.adobe.cq.media.publishing.dps.impl.contentsync.'\
  'DPSSubPagesUpdateHandler' do
  it 'there were 2 HTTP request (read + modify)' do
    expect(
      @osgi_config_helper.log_entries(
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
    ).to match(/\["foundation\/components\/image","test\/append\/value"\]/)
  end
end

describe 'OSGi com.day.cq.dam.scene7.impl.Scene7AssetMimeTypeServiceImpl' do
  it 'there was just a single request to read current values' do
    expect(
      @osgi_config_helper.log_entries(
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
    ).to match(%r{\["Generic=image/s7asset",
               "Template=image/s7template",
               "Flash=image/s7flashtemplate",
               "Image=image/jpeg",
               "Video=video/\*",
               "Video\.mp4=video/mp4",
               "Video\.f4v=video/mp4",
               "Video\.flv=video/x-flv"\]}x)
  end
end
