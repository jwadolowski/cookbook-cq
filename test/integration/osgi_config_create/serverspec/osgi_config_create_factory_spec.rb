require_relative '../../../kitchen/data/spec_helper'

describe 'Factory OSGi config com.example.random.factory' do
  it 'there was NO attemtps to create it' do
    expect(
      @osgi_config_helper.log_entries(
        'com.example.random.factory',
        '&factoryPid=com.example.random.factory&'
      ).length
    ).to eq(0)
  end

  it 'does NOT exist' do
    expect(
      @config_list.include?('com.example.random.factory')
    ).to be false
  end
end
