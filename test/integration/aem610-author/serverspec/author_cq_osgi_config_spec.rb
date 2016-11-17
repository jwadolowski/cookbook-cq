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
end

describe 'org.apache.sling.engine.impl.SlingMainServlet' do
  it 'sling.max.record.requests is set to 60' do
    expect(
      @osgi_config_helper.config_value(
        'org.apache.sling.engine.impl.SlingMainServlet',
        'sling.max.record.requests'
      )
    ).to eq(60)
  end
end
