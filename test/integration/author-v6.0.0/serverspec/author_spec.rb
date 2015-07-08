require 'serverspec'

set :backend, :exec

describe 'CQ author home directory' do
  it 'exists' do
    expect(file('/opt/cq/author')).to be_directory
  end

  it 'is owned by cq' do
    expect(file('/opt/cq/author')).to be_owned_by('cq')
  end

  it 'is grouped into cq' do
    expect(file('/opt/cq/author')).to be_grouped_into('cq')
  end

  it 'has 755 mode' do
    expect(file('/opt/cq/author')).to be_mode('755')
  end
end

describe 'CQ JAR file' do
  it 'exists in author instance home dir' do
    expect(
      command('ls -l /opt/cq/author').stdout
    ).to match(/cq-quickstart-6\.0\.0\.jar/)
  end

  it 'contains proper content' do
    expect(
      command('grep -i adobe /opt/cq/author/cq-quickstart-6.0.0.jar').stdout
    ).to match('matches')
  end

  it 'is owned by cq' do
    expect(file('/opt/cq/author/cq-quickstart-6.0.0.jar')).to be_owned_by('cq')
  end

  it 'is grouped into cq' do
    expect(
      file('/opt/cq/author/cq-quickstart-6.0.0.jar')
    ).to be_grouped_into('cq')
  end

  it 'is properly unpacked' do
    expect(file('/opt/cq/author/crx-quickstart')).to be_directory
    expect(file('/opt/cq/author/crx-quickstart')).to be_owned_by('cq')
    expect(file('/opt/cq/author/crx-quickstart')).to be_grouped_into('cq')
  end
end

describe 'CQ license file' do
  it 'exists in author instance home' do
    expect(file('/opt/cq/author/license.properties')).to be_file
  end

  it 'contains valid content' do
    expect(
      file('/opt/cq/author/license.properties').content
    ).to match('license.downloadID')
  end

  it 'is owned by cq' do
    expect(file('/opt/cq/author/license.properties')).to be_owned_by('cq')
  end

  it 'is grouped into cq' do
    expect(file('/opt/cq/author/license.properties')).to be_grouped_into('cq')
  end
end

describe 'CQ init script' do
  it 'exists' do
    expect(file('/etc/init.d/cq60-author')).to be_file
  end

  it 'is executable' do
    expect(file('/etc/init.d/cq60-author')).to be_executable
  end

  it 'is owned by root' do
    expect(file('/etc/init.d/cq60-author')).to be_owned_by('root')
  end

  it 'is grouped into root' do
    expect(file('/etc/init.d/cq60-author')).to be_grouped_into('root')
  end

  it 'contains valid content' do
    expect(
      file('/etc/init.d/cq60-author').content
    ).to match('PID_DIR="\$CQ_HOME/crx-quickstart/conf"')
    expect(
      file('/etc/init.d/cq60-author').content
    ).to match('KILL_DELAY=120')
    expect(
      file('/etc/init.d/cq60-author').content
    ).to match('sleep 5')
    expect(
      file('/etc/init.d/cq60-author').content
    ).to match(
      'CQ_CONF_FILE=/opt/cq/author/crx-quickstart/conf/cq60-author.conf')
    expect(
      file('/etc/init.d/cq60-author').content
    ).not_to match(
      'CQ_CONF_FILE=/opt/cq/publish/crx-quickstart/conf/cq60-author.conf')
  end
end

describe 'CQ author config file' do
  it 'exists' do
    expect(
      file('/opt/cq/author/crx-quickstart/conf/cq60-author.conf')
    ).to be_file
  end

  it 'is owned by cq' do
    expect(
      file('/opt/cq/author/crx-quickstart/conf/cq60-author.conf')
    ).to be_owned_by('cq')
  end

  it 'is grouped into cq' do
    expect(
      file('/opt/cq/author/crx-quickstart/conf/cq60-author.conf')
    ).to be_grouped_into('cq')
  end

  it 'contains valid content' do
    expect(
      file('/opt/cq/author/crx-quickstart/conf/cq60-author.conf').content
    ).to match('CQ_MIN_HEAP=256')
    expect(
      file('/opt/cq/author/crx-quickstart/conf/cq60-author.conf').content
    ).to match('export CQ_HOME=/opt/cq/author')
    expect(
      file('/opt/cq/author/crx-quickstart/conf/cq60-author.conf').content
    ).not_to match('export CQ_HOME=/opt/cq/publish')
    expect(
      file('/opt/cq/author/crx-quickstart/conf/cq60-author.conf').content
    ).to match('export CQ_PORT=4502')
    expect(
      file('/opt/cq/author/crx-quickstart/conf/cq60-author.conf').content
    ).not_to match('export CQ_PORT=4503')
  end
end

describe 'CQ author service' do
  it 'is running' do
    expect(service('cq60-author')).to be_running
  end

  it 'is enabled' do
    expect(service('cq60-author')).to be_enabled
  end
end

describe 'CQ PID file' do
  it 'exists' do
    expect(file('/opt/cq/author/crx-quickstart/conf/cq.pid')).to be_file
  end

  it 'is owned by cq' do
    expect(
      file('/opt/cq/author/crx-quickstart/conf/cq.pid')
    ).to be_owned_by('cq')
  end

  it 'is grouped into cq' do
    expect(
      file('/opt/cq/author/crx-quickstart/conf/cq.pid')
    ).to be_grouped_into('cq')
  end
end

describe 'CQ instance' do
  it 'is working properly' do
    expect(
      command(
        'curl http://localhost:4502/libs/granite/core/content/login.html'
      ).exit_status
    ).to eq 0
    expect(
      command(
        'curl http://localhost:4502/libs/granite/core/content/login.html '\
        '-sw "%{http_code}" -o /dev/null'
      ).stdout
    ).to match('200')
  end
end
