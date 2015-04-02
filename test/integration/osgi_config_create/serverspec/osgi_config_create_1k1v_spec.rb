require_relative '../../../kitchen/data/spec_helper'

describe 'OSGi config not.existing.config.create.1k1v.1' do
  it 'does NOT exists' do
    expect(
      @config_list.include?('not.existing.config.create.1k1v.1')
    ).to be false
  end

  it 'there was NO attempts to create it' do
    expect(
      @osgi_config_helper.log_entries_number(
        'access.log',
        'not\.existing\.config\.create\.1k1v\.1'
      )
    ).to eq(0)
  end
end

describe 'OSGi config '\
  'com.day.cq.dam.s7dam.common.S7damDamChangeEventListener' do
  it 'has cq.dam.s7dam.damchangeeventlistener.enabled set to false' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.dam.s7dam.common.S7damDamChangeEventListener',
        'cq.dam.s7dam.damchangeeventlistener.enabled'
      )
    ).to match(/^false$/)
  end

  # Two log entries - first one to get values, second to modify them
  it 'there was an attempt to modify it' do
    expect(
      @osgi_config_helper.log_entries_number(
        'access.log',
        'com\.day\.cq\.dam\.s7dam\.common\.S7damDamChangeEventListener'
      )
    ).to eq(2)
  end
end

describe 'OSGi config '\
  'com.day.cq.dam.scene7.impl.Scene7ConfigurationEventListener' do
  it 'has cq.dam.scene7.configurationeventlistener.enabled set to true' do
    expect(
      @osgi_config_helper.config_value(
        'com.day.cq.dam.scene7.impl.Scene7ConfigurationEventListener',
        'cq.dam.scene7.configurationeventlistener.enabled'
      )
    ).to match(/^true$/)
  end

  it 'there was NO attempts to modify it' do
    expect(
      @osgi_config_helper.log_entries_number(
        'access.log',
        'com\.day\.cq\.dam\.scene7\.impl\.Scene7ConfigurationEventListener'
      )
    ).to eq(0)
  end
end
