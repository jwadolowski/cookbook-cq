require_relative '../../../kitchen/data/spec_helper'

describe 'Slice 4.2.1' do
  it 'is uploaded' do
    expect(
      @package_helper.package_exists(
        'slice-assembly',
        '4\.2\.1',
        @package_list
      )
    ).to be true
  end

  it 'is installed' do
    expect(
      @package_helper.package_installed(
        'slice-assembly',
        '4\.2\.1',
        @package_list
      )
    ).to be true
  end
end

describe 'Slice Extension for AEM6' do
  it 'is uploaded' do
    expect(
      @package_helper.package_exists(
        'slice-aem60-assembly',
        '1\.1\.0',
        @package_list
      )
    ).to be true
  end

  it 'is installed' do
    expect(
      @package_helper.package_installed(
        'slice-aem60-assembly',
        '1\.1\.0',
        @package_list
      )
    ).to be true
  end
end

describe 'com.adobe.granite.platform.users' do
  it 'is uploaded' do
    expect(
      @package_helper.package_exists(
        'com.adobe.granite.platform.users',
        '1\.1\.4',
        @package_list
      )
    ).to be true
  end
end

describe 'cq-healthcheck-content' do
  it 'is installed' do
    expect(
      @package_helper.package_installed(
        'cq-healthcheck-content',
        '1\.0\.12',
        @package_list
      )
    ).to be true
  end
end

describe 'AEM Dash' do
  it 'is NOT uploaded' do
    expect(
      @package_helper.package_exists(
        'dash-full',
        '1\.2\.0',
        @package_list
      )
    ).to be false
  end

  it 'is NOT installed' do
    expect(
      @package_helper.package_installed(
        'dash-full',
        '1\.2\.0',
        @package_list
      )
    ).to be false
  end
end
