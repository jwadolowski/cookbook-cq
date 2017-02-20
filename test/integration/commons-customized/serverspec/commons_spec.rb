require 'serverspec'

set :backend, :exec

describe 'CQ base directory' do
  it 'exists' do
    expect(file('/opt')).to be_directory
  end

  it 'is owned by root' do
    expect(file('/opt')).to be_owned_by('root')
  end

  it 'is grouped into root' do
    expect(file('/opt')).to be_grouped_into('root')
  end

  it 'has mode 755' do
    expect(file('/opt')).to be_mode('755')
  end
end

describe 'AEM group' do
  it 'exists' do
    expect(group('aem')).to exist
  end

  it 'has GID 200' do
    expect(group('aem')).to have_gid('200')
  end
end

describe 'AEM user' do
  it 'exists' do
    expect(user('aem')).to exist
  end

  it 'has UID 200' do
    expect(user('aem')).to have_uid('200')
  end

  it 'belongs to group aem' do
    expect(user('aem')).to belong_to_group('aem')
  end

  it 'has its home directory in /opt/aem' do
    expect(user('aem')).to have_home_directory('/opt/aem')
  end

  it 'has login shell set to /bin/bash' do
    expect(user('aem')).to have_login_shell('/bin/sh')
  end

  it 'has comment set to "Adobe AEM"' do
    expect(command('grep -q "Adobe AEM" /etc/passwd').exit_status).to eq 0
  end
end

describe 'AEM user home' do
  it 'is directory' do
    expect(file('/opt/aem')).to be_directory
  end

  it 'has 755 mode' do
    expect(file('/opt/aem')).to be_mode('755')
  end
end

describe 'AEM user limits file' do
  it 'exists' do
    expect(file('/etc/security/limits.d/aem_limits.conf')).to be_file
  end

  it 'contains valid data' do
    expect(
      file('/etc/security/limits.d/aem_limits.conf').content
    ).to match('aem - nofile 16384')
  end

  it 'is owned by root' do
    expect(
      file('/etc/security/limits.d/aem_limits.conf')
    ).to be_owned_by('root')
  end

  it 'is grouped into root' do
    expect(
      file('/etc/security/limits.d/aem_limits.conf')
    ).to be_grouped_into('root')
  end

  it 'has 644 mode' do
    expect(file('/etc/security/limits.d/aem_limits.conf')).to be_mode('644')
  end
end

describe 'Custom tmp directory' do
  it 'exists' do
    expect(file('/opt/tmp')).to be_directory
  end

  it 'is owned by aem user' do
    expect(file('/opt/tmp')).to be_owned_by('aem')
  end

  it 'is grouped into aem' do
    expect(file('/opt/tmp')).to be_grouped_into('aem')
  end

  it 'has mode 755' do
    expect(file('/opt/tmp')).to be_mode('755')
  end
end

describe 'JDK' do
  it 'is installed' do
    expect(command('java -version').exit_status).to eq 0
    expect(command('which java').stdout).to match('/usr/bin/java')
    expect(file('/usr/bin/java')).to be_symlink
    expect(file('/usr/bin/java')).to be_linked_to('/etc/alternatives/java')
    expect(file('/etc/alternatives/java')).to be_symlink
    expect(file('/etc/alternatives/java')).to be_linked_to(
      '/usr/lib/jvm/java/bin/java'
    )
    expect(file('/usr/lib/jvm/java')).to be_symlink
    expect(
      command('ls -l /usr/lib/jvm/java').stdout
    ).to match(%r{/usr/lib/jvm/jdk.+})
    expect(
      command('ls -l /usr/lib/jvm/java').stdout
    ).not_to match(%r{/opt/.+})
  end
end

describe 'CQ UNIX Toolkit' do
  it 'is installed' do
    expect(file('/opt/scripts/CQ-Unix-Toolkit')).to be_directory
    expect(file('/opt/scripts/CQ-Unix-Toolkit/.git')).to be_directory
    expect(file('/opt/scripts/CQ-Unix-Toolkit/cqapi')).to be_executable
    expect(
      command('/opt/scripts/CQ-Unix-Toolkit/cqapi -v').exit_status
    ).to eq 0
  end
end
