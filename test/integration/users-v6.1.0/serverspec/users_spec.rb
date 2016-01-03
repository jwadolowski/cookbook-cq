require 'serverspec'

set :backend, :exec

describe 'User test1' do
  it 'does not exist' do
    expect(
      command(
        "curl -s -o /dev/null -w '%{http_code}' -u admin:passw0rd "\
        'http://localhost:4502/home/users/t/test1.json'
      ).stdout
    ).to match(/^404$/)
  end
end

describe 'Admin user' do
  before(:all) do
    cmd_str = 'curl -s -u admin:passw0rd \'http://localhost:4502/bin'\
    '/querybuilder.json?path=%2fhome%2fusers&property=rep%3aprincipalName&'\
    'property.value=admin\' | python -mjson.tool | '\
    'grep -oP \'(?<="path":\ ")([^"])+\''
    @admin_path = %x(#{cmd_str}).gsub(/\n/, "")
  end

  it "has password set to 'passw0rd'" do
    expect(
      command(
        "curl -s -o /dev/null -w '%{http_code}' -u admin:passw0rd "\
        'http://localhost:4502/libs/granite/core/content/login.html'
      ).stdout
    ).to match(/^200$/)
  end

  it 'lives in New York City' do
    expect(
      command(
        "curl -s -u admin:passw0rd "\
        "http://localhost:4502#{@admin_path}/profile.json "\
        '| python -mjson.tool | grep -oP \'"city":\ "\K[^"]+\''
      ).stdout
    ).to match(/^New\ York$/)
  end

  it 'last name is Kent' do
    expect(
      command(
        "curl -s -u admin:passw0rd "\
        "http://localhost:4502#{@admin_path}/profile.json "\
        '| python -mjson.tool | grep -oP \'"familyName":\ "\K[^"]+\''
      ).stdout
    ).to match(/^Kent$/)
  end
end

describe 'Author user' do
  it "is unable to log in" do
    expect(
      command(
        "curl -s -o /dev/null -w '%{http_code}' -u author:s3cret "\
        'http://localhost:4502/libs/granite/core/content/login.html'
      ).stdout
    ).to match(/^401$/)
  end

  it 'first name is John' do
    expect(
      command(
        "curl -s -u admin:passw0rd "\
        'http://localhost:4502/home/users/geometrixx/author/profile.json '\
        '| python -mjson.tool | grep -oP \'"givenName":\ "\K[^"]+\''
      ).stdout
    ).to match(/^John$/)
  end

  it 'holds Legacy Intranet Technician position' do
    expect(
      command(
        "curl -s -u admin:passw0rd "\
        'http://localhost:4502/home/users/geometrixx/author/profile.json '\
        '| python -mjson.tool | grep -oP \'"jobTitle":\ "\K[^"]+\''
      ).stdout
    ).to match(/^Legacy\ Intranet\ Technician$/)
  end
end
