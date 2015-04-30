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
  it 'there was an attempt to modify it' do
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

  # Just a single request to get current values
  it 'there was NO attempts to modify it' do
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
