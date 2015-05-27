require 'serverspec'

set :backend, :exec

describe 'CQ author config file' do
  it 'contains valid content' do
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
    expect(
      file('/opt/cq/author/crx-quickstart/conf/cq60-author.conf').content
    ).to match('export CQ_RUNMODE=crx2,author')
    expect(
      file('/opt/cq/author/crx-quickstart/conf/cq60-author.conf').content
    ).not_to match('export CQ_RUNMODE=author')
  end
end

describe 'CQ author service' do
  it 'is running' do
    expect(service('cq60-author')).to be_running
  end
end

describe 'CQ PID file' do
  it 'exists' do
    expect(file('/opt/cq/author/crx-quickstart/conf/cq.pid')).to be_file
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
        '-sw "%{http_code}"'
      ).stdout
    ).to match('200')
  end
end
