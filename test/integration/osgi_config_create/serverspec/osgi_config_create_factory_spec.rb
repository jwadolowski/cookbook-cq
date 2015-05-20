require_relative '../../../kitchen/data/spec_helper'

describe 'Factory OSGi config com.example.random.factory' do
  it 'there was NO attemtps to create it' do
    expect(
      @osgi_config_helper.factory_update_requests(
        'com.example.random.factory'
      ).length
    ).to eq(0)
  end

  it 'there was a single check to verify factory PID presence' do
    expect(
      @osgi_config_helper.factory_read_requests(
        'com.example.random.factory'
      ).length
    ).to eq(1)
  end

  it 'does NOT exist' do
    expect(
      @config_list.include?('com.example.random.factory')
    ).to be false
  end
end

describe 'Factory OSGi com.adobe.granite.monitoring.impl.ScriptConfigImpl' do
  it 'there was a single check to verify factory PID presence' do
    expect(
      @osgi_config_helper.factory_read_requests(
        'com.adobe.granite.monitoring.impl.ScriptConfigImpl'
      ).length
    ).to eq(1)
  end

  it 'there was a single HTTP POST request that sets all the data' do
    expect(
      @osgi_config_helper.factory_update_requests(
        'com.adobe.granite.monitoring.impl.ScriptConfigImpl'
      ).length
    ).to eq(1)
  end

  it '3 com.adobe.granite.monitoring.impl.ScriptConfigImpl instances exist' do
    expect(
      @osgi_config_helper.factory_instaces(
        'com.adobe.granite.monitoring.impl.ScriptConfigImpl'
      ).length
    ).to eq(3)
  end
end
