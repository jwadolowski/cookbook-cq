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

describe 'CQ group' do
  it 'exists' do
    expect(group('cq')).to exist
  end
end

describe 'CQ user' do
  it 'exists' do
    expect(user('cq')).to exist
  end

  it 'belongs to group cq' do
    expect(user('cq')).to belong_to_group('cq')
  end

  it 'has its home directory in /opt/cq' do
    expect(user('cq')).to have_home_directory('/opt/cq')
  end

  it 'has login shell set to /bin/bash' do
    expect(user('cq')).to have_login_shell('/bin/bash')
  end
end

describe 'CQ user home' do
  it 'is directory' do
    expect(file('/opt/cq')).to be_directory
  end

  it 'has 755 mode' do
    expect(file('/opt/cq')).to be_mode('755')
  end
end

describe 'CQ user limits file' do
  it 'exists' do
    expect(file('/etc/security/limits.d/cq_limits.conf')).to be_file
  end

  it 'contains valid data' do
    expect(
      file('/etc/security/limits.d/cq_limits.conf').content
    ).to match('cq - nofile 16384')
  end

  it 'is owned by root' do
    expect(
      file('/etc/security/limits.d/cq_limits.conf')
    ).to be_owned_by('root')
  end

  it 'is grouped into root' do
    expect(
      file('/etc/security/limits.d/cq_limits.conf')
    ).to be_grouped_into('root')
  end

  it 'has 644 mode' do
    expect(file('/etc/security/limits.d/cq_limits.conf')).to be_mode('644')
  end
end

describe 'Custom tmp directory' do
  it 'exists' do
    expect(file('/opt/tmp')).to be_directory
  end

  it 'is owned by cq user' do
    expect(file('/opt/tmp')).to be_owned_by('cq')
  end

  it 'is grouped into cq' do
    expect(file('/opt/tmp')).to be_grouped_into('cq')
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
