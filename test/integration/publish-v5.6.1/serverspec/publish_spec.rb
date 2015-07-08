require 'serverspec'

set :backend, :exec

describe 'CQ publish home directory' do
  it 'exists' do
    expect(file('/opt/cq/publish')).to be_directory
  end

  it 'is owned by cq' do
    expect(file('/opt/cq/publish')).to be_owned_by('cq')
  end

  it 'is grouped into cq' do
    expect(file('/opt/cq/publish')).to be_grouped_into('cq')
  end

  it 'has 755 mode' do
    expect(file('/opt/cq/publish')).to be_mode('755')
  end
end

describe 'CQ JAR file' do
  it 'exists in publish instance home dir' do
    expect(
      command('ls -l /opt/cq/publish').stdout
    ).to match(/cq-quickstart-5\.6\.1\.jar/)
  end

  it 'contains proper content' do
    expect(
      command('grep -i adobe /opt/cq/publish/cq-quickstart-5.6.1.jar').stdout
    ).to match('matches')
  end

  it 'is owned by cq' do
    expect(file('/opt/cq/publish/cq-quickstart-5.6.1.jar')).to be_owned_by('cq')
  end

  it 'is grouped into cq' do
    expect(
      file('/opt/cq/publish/cq-quickstart-5.6.1.jar')
    ).to be_grouped_into('cq')
  end

  it 'is properly unpacked' do
    expect(file('/opt/cq/publish/crx-quickstart')).to be_directory
    expect(file('/opt/cq/publish/crx-quickstart')).to be_owned_by('cq')
    expect(file('/opt/cq/publish/crx-quickstart')).to be_grouped_into('cq')
  end
end

describe 'CQ license file' do
  it 'exists in publish instance home' do
    expect(file('/opt/cq/publish/license.properties')).to be_file
  end

  it 'contains valid content' do
    expect(
      file('/opt/cq/publish/license.properties').content
    ).to match('license.downloadID')
  end

  it 'is owned by cq' do
    expect(file('/opt/cq/publish/license.properties')).to be_owned_by('cq')
  end

  it 'is grouped into cq' do
    expect(file('/opt/cq/publish/license.properties')).to be_grouped_into('cq')
  end
end

describe 'CQ init script' do
  it 'exists' do
    expect(file('/etc/init.d/cq56-publish')).to be_file
  end

  it 'is executable' do
    expect(file('/etc/init.d/cq56-publish')).to be_executable
  end

  it 'is owned by root' do
    expect(file('/etc/init.d/cq56-publish')).to be_owned_by('root')
  end

  it 'is grouped into root' do
    expect(file('/etc/init.d/cq56-publish')).to be_grouped_into('root')
  end

  it 'contains PID_DIR line' do
    expect(
      file('/etc/init.d/cq56-publish').content
    ).to match('PID_DIR="\$CQ_HOME/crx-quickstart/conf"')
  end

  it 'contains KILL_DELAY line' do
    expect(
      file('/etc/init.d/cq56-publish').content
    ).to match('KILL_DELAY=120')
  end

  it 'contains sleep between stop and start' do
    expect(
      file('/etc/init.d/cq56-publish').content
    ).to match('sleep 5')
  end

  it 'contains CQ_CONF_FILE varialbe for publish' do
    expect(
      file('/etc/init.d/cq56-publish').content
    ).to match(
      'CQ_CONF_FILE=/opt/cq/publish/crx-quickstart/conf/cq56-publish.conf')
  end

  it 'does not contain CQ_CONF_FILE variable for author' do
    expect(
      file('/etc/init.d/cq56-publish').content
    ).not_to match(
      'CQ_CONF_FILE=/opt/cq/publish/crx-quickstart/conf/cq56-author.conf')
  end
end

describe 'CQ publish config file' do
  it 'exists' do
    expect(
      file('/opt/cq/publish/crx-quickstart/conf/cq56-publish.conf')
    ).to be_file
  end

  it 'is owned by cq' do
    expect(
      file('/opt/cq/publish/crx-quickstart/conf/cq56-publish.conf')
    ).to be_owned_by('cq')
  end

  it 'is grouped into cq' do
    expect(
      file('/opt/cq/publish/crx-quickstart/conf/cq56-publish.conf')
    ).to be_grouped_into('cq')
  end

  it 'contains valid content' do
    expect(
      file('/opt/cq/publish/crx-quickstart/conf/cq56-publish.conf').content
    ).to match('CQ_MIN_HEAP=256')
    expect(
      file('/opt/cq/publish/crx-quickstart/conf/cq56-publish.conf').content
    ).to match('export CQ_HOME=/opt/cq/publish')
    expect(
      file('/opt/cq/publish/crx-quickstart/conf/cq56-publish.conf').content
    ).not_to match('export CQ_HOME=/opt/cq/author')
    expect(
      file('/opt/cq/publish/crx-quickstart/conf/cq56-publish.conf').content
    ).to match('export CQ_PORT=4503')
    expect(
      file('/opt/cq/publish/crx-quickstart/conf/cq56-publish.conf').content
    ).not_to match('export CQ_PORT=4502')
  end
end

describe 'CQ publish service' do
  it 'is running' do
    expect(service('cq56-publish')).to be_running
  end

  it 'is enabled' do
    expect(service('cq56-publish')).to be_enabled
  end
end

describe 'CQ PID file' do
  it 'exists' do
    expect(file('/opt/cq/publish/crx-quickstart/conf/cq.pid')).to be_file
  end

  it 'is owned by cq' do
    expect(
      file('/opt/cq/publish/crx-quickstart/conf/cq.pid')
    ).to be_owned_by('cq')
  end

  it 'is grouped into cq' do
    expect(
      file('/opt/cq/publish/crx-quickstart/conf/cq.pid')
    ).to be_grouped_into('cq')
  end
end

describe 'CQ instance' do
  it 'is working properly' do
    expect(
      command(
        'curl http://localhost:4503/libs/granite/core/content/login.html'
      ).exit_status
    ).to eq 0
    expect(
      command(
        'curl http://localhost:4503/libs/granite/core/content/login.html '\
        '-sw "%{http_code}" -o /dev/null'
      ).stdout
    ).to match('200')
  end
end
