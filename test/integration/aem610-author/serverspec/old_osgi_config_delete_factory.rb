require_relative '../../../kitchen/data/spec_helper'

describe 'Factory OSGi org.apache.sling.tenant.internal.TenantProviderImpl' do
  it 'there was a single check to verify factory PID presence' do
    expect(
      @osgi_config_helper.read_requests(
        'org.apache.sling.tenant.internal.TenantProviderImpl'
      ).length
    ).to eq(1)
  end

  it 'in total there was 1 HTTP request' do
    expect(
      @osgi_config_helper.all_requests(
        'org.apache.sling.tenant.internal.TenantProviderImpl'
      ).length
    ).to eq(1)
  end
end

describe 'Factory OSGi org.apache.sling.commons.log.LogManager.factory.'\
  'writer' do
  it 'there was a single check to verify factory PID presence' do
    expect(
      @osgi_config_helper.read_requests(
        'org.apache.sling.commons.log.LogManager.factory.writer'
      ).length
    ).to eq(1)
  end

  # 1) Read factory PID
  # 2) Read 1st instance
  it 'in total there were 2 HTTP requests' do
    expect(
      @osgi_config_helper.all_requests(
        'org.apache.sling.commons.log.LogManager.factory.writer'
      ).length
    ).to eq(2)
  end

  it '1 instance of org.apache.sling.commons.log.LogManager.factory.writer '\
    'exists' do
    expect(
      @osgi_config_helper.factory_instaces(
        'org.apache.sling.commons.log.LogManager.factory.writer'
      ).length
    ).to eq(1)
  end
end

describe 'Factory OSGi org.apache.sling.event.jobs.QueueConfiguration' do
  # 1) Read factory PID
  # 2) - 13) Read all instances
  # 14) Re-read best pid
  it 'in total there were 14 HTTP requests' do
    expect(
      @osgi_config_helper.all_requests(
        'org.apache.sling.event.jobs.QueueConfiguration'
      ).length
    ).to eq(14)
  end

  it '12 instances of org.apache.sling.event.jobs.QueueConfiguration exist' do
    expect(
      @osgi_config_helper.factory_instaces(
        'org.apache.sling.event.jobs.QueueConfiguration'
      ).length
    ).to eq(12)
  end
end
