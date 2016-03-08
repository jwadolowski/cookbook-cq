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

describe 'cq-security-content' do
  it 'is uploaded' do
    expect(
      @package_helper.package_exists(
        'cq-security-content',
        '1\.1\.6',
        @package_list
      )
    ).to be true
  end
end

describe 'cq-compat-content' do
  it 'is installed' do
    expect(
      @package_helper.package_installed(
        'cq-compat-content',
        '1\.1\.44',
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

describe 'Oak 1.2.7' do
  it 'is uploaded' do
    expect(
      @package_helper.package_exists(
        'cq-6.1.0-hotfix-7700',
        '2\.2',
        @package_list
      )
    ).to be true
  end

  it 'is installed' do
    expect(
      @package_helper.package_installed(
        'cq-6.1.0-hotfix-7700',
        '2\.2',
        @package_list
      )
    ).to be true
  end
end

describe 'ACS AEM Commons' do
  it 'version 1.9.6 is uploaded' do
    expect(
      @package_helper.package_exists(
        'acs-aem-commons-content',
        '1\.9\.6',
        @package_list
      )
    ).to be true
  end

  it 'version 1.9.6 is installed' do
    expect(
      @package_helper.package_installed(
        'acs-aem-commons-content',
        '1\.9\.6',
        @package_list
      )
    ).to be true
  end

  it 'version 1.10.0 is uploaded' do
    expect(
      @package_helper.package_exists(
        'acs-aem-commons-content',
        '1\.10\.0',
        @package_list
      )
    ).to be true
  end

  it 'version 1.10.0 was installed' do
    expect(
      @package_helper.package_installed(
        'acs-aem-commons-content',
        '1\.10\.0',
        @package_list
      )
    ).to be true
  end

  it 'version 1.10.2 is uploaded' do
    expect(
      @package_helper.package_exists(
        'acs-aem-commons-content',
        '1\.10\.2',
        @package_list
      )
    ).to be true
  end

  it 'version 1.10.2 is NOT installed' do
    expect(
      @package_helper.package_installed(
        'acs-aem-commons-content',
        '1\.10\.2',
        @package_list
      )
    ).to be false
  end
end

describe 'Hotfix 6449' do
  it 'is uploaded' do
    expect(
      @package_helper.package_exists(
        'cq-6.1.0-hotfix-6449',
        '1\.2',
        @package_list
      )
    ).to be true
  end

  it 'is installed' do
    expect(
      @package_helper.package_installed(
        'cq-6.1.0-hotfix-6449',
        '1\.2',
        @package_list
      )
    ).to be true

    expect(
      @package_helper.package_installed(
        'cq-dam-bundles-content',
        '1\.0\.236',
        @package_list
      )
    ).to be true
  end
end

describe 'Hotfix 7085' do
  it 'is uploaded' do
    expect(
      @package_helper.package_exists(
        'cq-6.1.0-hotfix-7085',
        '1\.0',
        @package_list
      )
    ).to be true
  end

  it 'is installed' do
    expect(
      @package_helper.package_installed(
        'cq-6.1.0-hotfix-7085',
        '1\.0',
        @package_list
      )
    ).to be true

    expect(
      @package_helper.package_installed(
        'com.adobe.granite.ui.content',
        '0\.7\.154-CQ610-B0008',
        @package_list
      )
    ).to be true
  end
end

describe 'Hotfix 6446' do
  it 'is uploaded' do
    expect(
      @package_helper.package_exists(
        'cq-6.1.0-hotfix-6446',
        '1\.0',
        @package_list
      )
    ).to be true
  end

  it 'is installed' do
    expect(
      @package_helper.package_installed(
        'cq-6.1.0-hotfix-6446',
        '1\.0',
        @package_list
      )
    ).to be true
  end
end

describe 'Hotfix 6500' do
  it 'is uploaded' do
    expect(
      @package_helper.package_exists(
        'cq-6.1.0-hotfix-6500',
        '1\.0',
        @package_list
      )
    ).to be true
  end

  it 'is installed' do
    expect(
      @package_helper.package_installed(
        'cq-6.1.0-hotfix-6500',
        '1\.0',
        @package_list
      )
    ).to be true

    expect(
      @package_helper.package_installed(
        'cq-dam-content',
        '2\.1\.296',
        @package_list
      )
    ).to be true
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

  it 'its subpackages are NOT uploaded' do
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

  it 'is NOT installed' do
    expect(
      @package_helper.package_installed(
        'cq-geometrixx-all-pkg',
        '5\.8\.392',
        @package_list
      )
    ).to be false
  end

  it 'its subpackages are NOT installed' do
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

describe 'SP1' do
  it 'is uploaded' do
    expect(
      @package_helper.package_exists(
        'aem-service-pkg',
        '6\.1\.SP1',
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
        'cq-platform-content',
        '1\.1\.864',
        @package_list
      )
    ).to be true
  end

  it 'is installed' do
    expect(
      @package_helper.package_installed(
        'aem-service-pkg',
        '6\.1\.SP1',
        @package_list
      )
    ).to be true
  end

  it 'its subpackages are installed' do
    expect(
      @package_helper.package_installed(
        'cq-address-content',
        '1\.1\.16',
        @package_list
      )
    ).to be true

    expect(
      @package_helper.package_installed(
        'cq-dam-bundles-content',
        '1\.0\.290',
        @package_list
      )
    ).to be true
  end
end
