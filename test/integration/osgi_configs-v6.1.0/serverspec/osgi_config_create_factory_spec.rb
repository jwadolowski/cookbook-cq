require_relative '../../../kitchen/data/spec_helper'

describe 'Factory OSGi com.adobe.granite.monitoring.impl.ScriptConfigImpl' do
  it 'there was 1 create new factory request' do
    expect(
      @osgi_config_helper.factory_create_requests(
        'com.adobe.granite.monitoring.impl.ScriptConfigImpl'
      ).length
    ).to eq(1)
  end

  # 1) Get default config
  # 2) Get 1st instance
  # 3) Get 2nd instance
  it 'in total there were 3 HTTP requests that included PID' do
    expect(
      @osgi_config_helper.all_requests(
        'com.adobe.granite.monitoring.impl.ScriptConfigImpl'
      ).length
    ).to eq(3)
  end

  it '3 instances exist' do
    expect(
      @osgi_config_helper.factory_instaces(
        'com.adobe.granite.monitoring.impl.ScriptConfigImpl'
      ).length
    ).to eq(3)
  end
end

describe 'Factory OSGi com.adobe.cq.social.datastore.as.impl.'\
  'UGCCResourceProviderFactory' do
  it 'there were 2 create new factory requests' do
    expect(
      @osgi_config_helper.factory_create_requests(
        'com.adobe.cq.social.datastore.as.impl.UGCCResourceProviderFactory'
      ).length
    ).to eq(2)
  end

  # 1) Get default config
  # 2) Get 1st instance
  # 3) Update 1st instance
  it 'in total there were 3 HTTP requests that included PID' do
    expect(
      @osgi_config_helper.all_requests(
        'com.adobe.cq.social.datastore.as.impl.UGCCResourceProviderFactory'
      ).length
    ).to eq(3)
  end

  it '3 instances exist' do
    expect(
      @osgi_config_helper.factory_instaces(
        'com.adobe.granite.monitoring.impl.ScriptConfigImpl'
      ).length
    ).to eq(3)
  end
end

describe 'Factory OSGi com.day.cq.mcm.impl.MCMConfiguration' do
  it 'there was 0 create new factory requests' do
    expect(
      @osgi_config_helper.factory_create_requests(
        'com.day.cq.mcm.impl.MCMConfiguration'
      ).length
    ).to eq(0)
  end

  # 1) Get default config
  # 2) Get 1st instance
  it 'in total there were 2 HTTP requests that included PID' do
    expect(
      @osgi_config_helper.all_requests(
        'com.day.cq.mcm.impl.MCMConfiguration'
      ).length
    ).to eq(2)
  end

  it '1 instance exist' do
    expect(
      @osgi_config_helper.factory_instaces(
        'com.day.cq.mcm.impl.MCMConfiguration'
      ).length
    ).to eq(1)
  end
end

describe 'Factory OSGi com.adobe.granite.auth.oauth.provider' do
  it 'there was 1 create new factory requests' do
    expect(
      @osgi_config_helper.factory_create_requests(
        'com.adobe.granite.auth.oauth.provider'
      ).length
    ).to eq(1)
  end

  # 1) Get default config
  # 2) Get 1st instance
  # 2) Get 2nd instance
  it 'in total there were 3 HTTP requests that included PID' do
    expect(
      @osgi_config_helper.all_requests(
        'com.adobe.granite.auth.oauth.provider'
      ).length
    ).to eq(3)
  end

  it '3 instances exist' do
    expect(
      @osgi_config_helper.factory_instaces(
        'com.adobe.granite.auth.oauth.provider'
      ).length
    ).to eq(3)
  end
end

describe 'Factory OSGi org.apache.sling.commons.log.LogManager.factory'\
  '.config' do
  it 'there was 0 create new factory requests' do
    expect(
      @osgi_config_helper.factory_create_requests(
        'org.apache.sling.commons.log.LogManager.factory.config'
      ).length
    ).to eq(0)
  end

  # 1) Get default config
  # 2) Get 1st instance
  # 3) Get 2nd instance
  # 4) Get 3rd instance
  # 5) Get 4th instance
  # 6) Get 5th instance
  # 7) Get 6th instance
  # 8) Get 7th instance
  it 'in total there were 8 HTTP requests that included PID' do
    expect(
      @osgi_config_helper.all_requests(
        'org.apache.sling.commons.log.LogManager.factory.config'
      ).length
    ).to eq(8)
  end

  it '7 instances exist' do
    expect(
      @osgi_config_helper.factory_instaces(
        'org.apache.sling.commons.log.LogManager.factory.config'
      ).length
    ).to eq(7)
  end
end
