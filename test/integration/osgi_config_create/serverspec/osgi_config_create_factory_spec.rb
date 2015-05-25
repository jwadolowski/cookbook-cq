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
      @osgi_config_helper.read_requests(
        'com.example.random.factory'
      ).length
    ).to eq(1)
  end

  it 'does NOT exist' do
    expect(
      @config_list.include?('com.example.random.factory')
    ).to be false
  end

  it 'in total there was 1 HTTP request' do
    expect(
      @osgi_config_helper.all_requests(
        'com.example.random.factory'
      ).length
    ).to eq(1)
  end
end

describe 'Factory OSGi com.adobe.granite.monitoring.impl.ScriptConfigImpl' do
  it 'there was a single check to verify factory PID presence' do
    expect(
      @osgi_config_helper.read_requests(
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

  # 1) Get factory PID
  # 2) Get 1st existing instance
  # 3) Get 2nd existing instance
  # 4) Create request
  it 'in total there were 4 HTTP requests' do
    expect(
      @osgi_config_helper.all_requests(
        'com.adobe.granite.monitoring.impl.ScriptConfigImpl'
      ).length
    ).to eq(4)
  end
end

describe 'Factory OSGi com.day.cq.mcm.impl.MCMConfiguration' do
  it 'there was a single check to verify factory PID presence' do
    expect(
      @osgi_config_helper.read_requests(
        'com.day.cq.mcm.impl.MCMConfiguration'
      ).length
    ).to eq(1)
  end

  it "UPDATE request hasn't been sent" do
    expect(
      @osgi_config_helper.factory_update_requests(
        'com.day.cq.mcm.impl.MCMConfiguration'
      ).length
    ).to eq(0)
  end

  it 'single com.day.cq.mcm.impl.MCMConfiguration instance exists' do
    expect(
      @osgi_config_helper.factory_instaces(
        'com.day.cq.mcm.impl.MCMConfiguration'
      ).length
    ).to eq(1)
  end

  # 1) Read factory PID
  # 2) Read 1st instance settings
  # 3) Read properties for factory instance that has been found (can be
  #    improved as stated in CHEF-155)
  it 'in total there were 3 HTTP requests' do
    expect(
      @osgi_config_helper.all_requests(
        'com.day.cq.mcm.impl.MCMConfiguration'
      ).length
    ).to eq(3)
  end
end

describe 'Factory OSGi com.adobe.granite.auth.oauth.provider' do
  it 'in total there was 0 HTTP requests' do
    expect(
      @osgi_config_helper.all_requests(
        'com.adobe.granite.auth.oauth.provider'
      ).length
    ).to eq(0)
  end
end

describe 'Factory OSGi org.apache.sling.commons.log.LogManager.factory'\
  '.config' do
  it 'in total there was 0 HTTP requests' do
    expect(
      @osgi_config_helper.all_requests(
        'org.apache.sling.commons.log.LogManager.factory.config'
      ).length
    ).to eq(0)
  end
end
