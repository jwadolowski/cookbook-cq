require_relative '../../../kitchen/data/spec_helper'

describe 'SP2' do
  it 'is uploaded' do
    expect(
      @package_helper.package_exists(
        'aem-service-pkg',
        '6\.1\.SP2',
        @package_list
      )
    ).to be true
  end

  it 'its subpackages are uploaded' do
    expect(
      @package_helper.package_exists(
        'cq-serialization-agent-acl-content',
        '1\.0\.8',
        @package_list
      )
    ).to be true

    expect(
      @package_helper.package_exists(
        'com.adobe.granite.platform.content',
        '0\.5\.20-CQ610-B0008',
        @package_list
      )
    ).to be true
  end

  it 'is installed' do
    expect(
      @package_helper.package_installed(
        'aem-service-pkg',
        '6\.1\.SP2',
        @package_list
      )
    ).to be true
  end

  it 'its subpackages are installed' do
    expect(
      @package_helper.package_installed(
        'com.adobe.granite.platform.clientlibs',
        '1\.1\.86-CQ610-B0005',
        @package_list
      )
    ).to be true

    expect(
      @package_helper.package_installed(
        'com.adobe.reef.contexthub.content',
        '0\.0\.208',
        @package_list
      )
    ).to be true
  end
end
