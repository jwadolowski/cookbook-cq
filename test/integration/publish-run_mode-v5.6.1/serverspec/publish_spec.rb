require 'serverspec'

set :backend, :exec

describe 'CQ publish config file' do
  it 'contains valid content' do
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
    expect(
      file('/opt/cq/publish/crx-quickstart/conf/cq56-publish.conf').content
    ).to match('export CQ_RUNMODE=crx2,publish')
    expect(
      file('/opt/cq/publish/crx-quickstart/conf/cq56-publish.conf').content
    ).not_to match('export CQ_RUNMODE=publish')
  end
end

describe 'CQ publish service' do
  it 'is running' do
    expect(service('cq56-publish')).to be_running
  end
end

describe 'CQ PID file' do
  it 'exists' do
    expect(file('/opt/cq/publish/crx-quickstart/conf/cq.pid')).to be_file
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
        '-sw "%{http_code}"'
      ).stdout
    ).to match('200')
  end
end
