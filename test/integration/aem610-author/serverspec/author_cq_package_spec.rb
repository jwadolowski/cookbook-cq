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
        'com.adobe.granite.workflow.content.61sp1',
        '1.16',
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
        'cq-mobile-phonegap-content',
        '6\.1\.58',
        @package_list
      )
    ).to be true

    expect(
      @package_helper.package_installed(
        'aem-service-pkg-bundles',
        '6\.1\.SP2',
        @package_list
      )
    ).to be true
  end
end

describe 'SP2 CFP3' do
  it 'is uploaded' do
    expect(
      @package_helper.package_exists(
        'cq-6.1.0-sp2-cfp-wrapper',
        '3\.0',
        @package_list
      )
    ).to be true
  end

  it 'its subpackages are uploaded' do
    expect(
      @package_helper.package_exists(
        'cq-6.1.0-sp2-cfp',
        '3\.0',
        @package_list
      )
    ).to be true

    expect(
      @package_helper.package_exists(
        'com.adobe.granite.references.content',
        '1\.0\.92-CQ610-B0002',
        @package_list
      )
    ).to be true
  end

  it 'is installed' do
    expect(
      @package_helper.package_installed(
        'cq-6.1.0-sp2-cfp-wrapper',
        '3\.0',
        @package_list
      )
    ).to be true
  end

  it 'its subpackages are installed' do
    expect(
      @package_helper.package_installed(
        'cq-6.1.0-sp2-cfp-bundles',
        '3\.0',
        @package_list
      )
    ).to be true

    expect(
      @package_helper.package_installed(
        'cq-dam-content',
        '2\.1\.512',
        @package_list
      )
    ).to be true
  end
end

describe 'Slice' do
  it 'is uploaded' do
    expect(
      @package_helper.package_exists(
        'slice-assembly',
        '4\.3\.1',
        @package_list
      )
    ).to be true
  end

  it 'is installed' do
    expect(
      @package_helper.package_installed(
        'slice-assembly',
        '4\.3\.1',
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
        '1\.2\.0',
        @package_list
      )
    ).to be true
  end

  it 'is installed' do
    expect(
      @package_helper.package_installed(
        'slice-aem60-assembly',
        '1\.2\.0',
        @package_list
      )
    ).to be true
  end
end

describe 'com.adobe.granite.httpcache.content' do
  it 'is uploaded' do
    expect(
      @package_helper.package_exists(
        'com.adobe.granite.httpcache.content',
        '1\.0\.2',
        @package_list
      )
    ).to be true
  end
end

describe 'cq-chart-content' do
  it 'is installed' do
    expect(
      @package_helper.package_installed(
        'cq-chart-content',
        '1\.0\.2',
        @package_list
      )
    ).to be true
  end
end

describe 'AEM Dash' do
  it 'is not uploaded' do
    expect(
      @package_helper.package_exists(
        'dash-full',
        '1\.2\.0',
        @package_list
      )
    ).to be false
  end
end

describe 'ACS AEM Commons' do
  it 'version 2.8.0 is uploaded' do
    expect(
      @package_helper.package_exists(
        'acs-aem-commons-content',
        '2\.8\.0',
        @package_list
      )
    ).to be true
  end

  it 'version 2.8.2 is uploaded' do
    expect(
      @package_helper.package_exists(
        'acs-aem-commons-content',
        '2\.8\.2',
        @package_list
      )
    ).to be true
  end

  it 'version 2.9.0 is uploaded' do
    expect(
      @package_helper.package_exists(
        'acs-aem-commons-content',
        '2\.9\.0',
        @package_list
      )
    ).to be true
  end


  it 'version 2.8.0 is installed' do
    expect(
      @package_helper.package_installed(
        'acs-aem-commons-content',
        '2\.8\.0',
        @package_list
      )
    ).to be true
  end

  it 'version 2.8.2 was installed' do
    expect(
      @package_helper.package_installed(
        'acs-aem-commons-content',
        '2\.8\.2',
        @package_list
      )
    ).to be true
  end

  it 'version 2.9.0 is not installed' do
    expect(
      @package_helper.package_installed(
        'acs-aem-commons-content',
        '2\.9\.0',
        @package_list
      )
    ).to be false
  end
end

describe 'Geometrixx package' do
  it 'is uploaded' do
    expect(
      @package_helper.package_exists(
        'cq-geometrixx-all-pkg',
        '5\.8\.392',
        @package_list
      )
    ).to be true
  end

  it 'its subpackages are not uploaded' do
    expect(
      @package_helper.package_exists(
        'cq-geometrixx-media-ugc-pkg',
        '5\.8\.10',
        @package_list
      )
    ).to be false

    expect(
      @package_helper.package_exists(
        'cq-geometrixx-users-pkg',
        '5\.8\.12',
        @package_list
      )
    ).to be false
  end

  it 'is not installed' do
    expect(
      @package_helper.package_installed(
        'cq-geometrixx-all-pkg',
        '5\.8\.392',
        @package_list
      )
    ).to be false
  end

  it 'its subpackages are not installed' do
    expect(
      @package_helper.package_installed(
        'cq-geometrixx-media-ugc-pkg',
        '5\.8\.10',
        @package_list
      )
    ).to be false

    expect(
      @package_helper.package_installed(
        'cq-geometrixx-users-pkg',
        '5\.8\.12',
        @package_list
      )
    ).to be false
  end
end

describe 'Groovy Console' do
  it 'is not uploaded' do
    expect(
      @package_helper.package_exists(
        'aem-groovy-console',
        '8\.0\.2',
        @package_list
      )
    ).to be false
  end
end
