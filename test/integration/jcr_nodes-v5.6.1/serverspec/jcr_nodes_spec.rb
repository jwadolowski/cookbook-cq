require 'serverspec'

set :backend, :exec

describe '/content/test1' do
  it 'exists' do
    expect(
      command(
        "curl -s -o /dev/null -w '%{http_code}' -u admin:admin "\
        'http://localhost:4502/content/test1.json'
      ).stdout
    ).to match(/^200$/)
  end
end

describe '/content/testXYZ' do
  it 'exists' do
    expect(
      command(
        "curl -s -o /dev/null -w '%{http_code}' -u admin:admin "\
        'http://localhost:4502/content/testXYZ.json'
      ).stdout
    ).to match(/^200$/)
  end
end

describe '/content/test2' do
  it 'exists' do
    expect(
      command(
        "curl -s -o /dev/null -w '%{http_code}' -u admin:admin "\
        'http://localhost:4502/content/test2.json'
      ).stdout
    ).to match(/^200$/)
  end

  it 'property property_one equals first' do
    expect(
      command(
        'curl -s -u admin:admin '\
        'http://localhost:4502/content/test2.json '\
        '| python -c '\
        "'import sys, json; print json.load(sys.stdin)[\"property_one\"]'"
      ).stdout
    ).to match(/^first$/)
  end

  it 'property property_two equals second' do
    expect(
      command(
        'curl -s -u admin:admin '\
        'http://localhost:4502/content/test2.json '\
        '| python -c '\
        "'import sys, json; print json.load(sys.stdin)[\"property_two\"]'"
      ).stdout
    ).to match(/^second$/)
  end

  it 'property property_three equals third' do
    expect(
      command(
        'curl -s -u admin:admin '\
        'http://localhost:4502/content/test2.json '\
        '| python -c '\
        "'import sys, json; print json.load(sys.stdin)[\"property_three\"]'"
      ).stdout
    ).to match(/^third$/)
  end
end

describe '/content/Special_%characters (test)' do
  it 'exists' do
    expect(
      command(
        "curl -s -o /dev/null -w '%{http_code}' -u admin:admin "\
        '\'http://localhost:4502/content/Special_%25characters%20(test).json\''
      ).stdout
    ).to match(/^200$/)
  end

  it 'property p1 equals 100' do
    expect(
      command(
        'curl -s -u admin:admin '\
        '\'http://localhost:4502/content'\
        '/Special_%25characters%20(test).json\'' \
        '| python -c '\
        "'import sys, json; print json.load(sys.stdin)[\"p1\"]'"
      ).stdout
    ).to match(/^100$/)
  end

  it 'property p2 equals 200' do
    expect(
      command(
        'curl -s -u admin:admin '\
        '\'http://localhost:4502/content'\
        '/Special_%25characters%20(test).json\'' \
        '| python -c '\
        "'import sys, json; print json.load(sys.stdin)[\"p2\"]'"
      ).stdout
    ).to match(/^200$/)
  end

  it 'property p3 equals 300' do
    expect(
      command(
        'curl -s -u admin:admin '\
        '\'http://localhost:4502/content'\
        '/Special_%25characters%20(test).json\'' \
        '| python -c '\
        "'import sys, json; print json.load(sys.stdin)[\"p3\"]'"
      ).stdout
    ).to match(/^300$/)
  end
end

describe '/content/geometrixx/en/events/userconf/jcr:content' do
  it 'exists' do
    expect(
      command(
        "curl -s -o /dev/null -w '%{http_code}' -u admin:admin "\
        'http://localhost:4502'\
        '/content/geometrixx/en/events/userconf/jcr:content.json'
      ).stdout
    ).to match(/^200$/)
  end

  it 'was modified in 2011' do
    expect(
      command(
        'curl -s -u admin:admin '\
        'http://localhost:4502'\
        '/content/geometrixx/en/events/userconf/jcr:content.json'\
        '| python -c '\
        "'import sys, json; print json.load(sys.stdin)[\"cq:lastModified\"]'"\
        "| grep '2011'"
      ).exit_status
    ).to eq 0
  end
end

describe '/content/geometrixx/en/company/jcr:content' do
  it 'exists' do
    expect(
      command(
        "curl -s -o /dev/null -w '%{http_code}' -u admin:admin "\
        'http://localhost:4502/content/geometrixx/en/company/jcr:content.json'
      ).stdout
    ).to match(/^200$/)
  end

  it 'property jcr:title equals Geometrixx Company' do
    expect(
      command(
        'curl -s -u admin:admin '\
        'http://localhost:4502/content/geometrixx/en/company/jcr:content.json'\
        '| python -c '\
        "'import sys, json; print json.load(sys.stdin)[\"jcr:title\"]'"
      ).stdout
    ).to match(/^Geometrixx\ Company$/)
  end
end

describe '/content/geometrixx/de/support/jcr:content' do
  it 'exists' do
    expect(
      command(
        "curl -s -o /dev/null -w '%{http_code}' -u admin:admin "\
        'http://localhost:4502'\
        '/content/geometrixx/de/support/jcr:content.json'
      ).stdout
    ).to match(/^200$/)
  end

  it 'was modified in 2010' do
    expect(
      command(
        'curl -s -u admin:admin '\
        'http://localhost:4502'\
        '/content/geometrixx/de/support/jcr:content.json'\
        '| python -c '\
        "'import sys, json; print json.load(sys.stdin)[\"cq:lastModified\"]'"\
        "| grep '2010'"
      ).exit_status
    ).to eq 0
  end
end

describe '/content/geometrixx/en/products/jcr:content' do
  it 'exists' do
    expect(
      command(
        "curl -s -o /dev/null -w '%{http_code}' -u admin:admin "\
        'http://localhost:4502'\
        '/content/geometrixx/en/products/jcr:content.json'
      ).stdout
    ).to match(/^200$/)
  end

  it 'property jcr:primaryType equals cq:PageContent' do
    expect(
      command(
        'curl -s -u admin:admin '\
        'http://localhost:4502'\
        '/content/geometrixx/en/products/jcr:content.json'\
        '| python -c '\
        "'import sys, json; print json.load(sys.stdin)[\"jcr:primaryType\"]'"
      ).stdout
    ).to match(/^cq:PageContent$/)
  end

  it 'property jcr:title equals New title' do
    expect(
      command(
        'curl -s -u admin:admin '\
        'http://localhost:4502'\
        '/content/geometrixx/en/products/jcr:content.json'\
        '| python -c '\
        "'import sys, json; print json.load(sys.stdin)[\"jcr:title\"]'"
      ).stdout
    ).to match(/^New\ title$/)
  end

  it 'property subtitle equals New subtitle' do
    expect(
      command(
        'curl -s -u admin:admin '\
        'http://localhost:4502'\
        '/content/geometrixx/en/products/jcr:content.json'\
        '| python -c '\
        "'import sys, json; print json.load(sys.stdin)[\"subtitle\"]'"
      ).stdout
    ).to match(/^New\ subtitle$/)
  end

  it 'property new_property equals Random value' do
    expect(
      command(
        'curl -s -u admin:admin '\
        'http://localhost:4502'\
        '/content/geometrixx/en/products/jcr:content.json'\
        '| python -c '\
        "'import sys, json; print json.load(sys.stdin)[\"new_property\"]'"
      ).stdout
    ).to match(/^Random\ value$/)
  end
end

describe '/content/dam/geometrixx-media/articles/en/2012' do
  it 'does not exist' do
    expect(
      command(
        "curl -s -o /dev/null -w '%{http_code}' -u admin:admin "\
        'http://localhost:4502'\
        '/content/dam/geometrixx-media/articles/en/2012.json'
      ).stdout
    ).to match(/^404$/)
  end
end

describe '/content/dam/geometrixx-outdoors/products/glasses'\
  '/Raja%20Ampat.jpg' do
  it 'does not exist' do
    expect(
      command(
        "curl -s -o /dev/null -w '%{http_code}' -u admin:admin "\
        'http://localhost:4502'\
        '/content/dam/geometrixx-outdoors/products/glasses/Raja%20Ampat.jpg'
      ).stdout
    ).to match(/^404$/)
  end
end

describe '/path/to/not/exising/node' do
  it 'does not exist' do
    expect(
      command(
        "curl -s -o /dev/null -w '%{http_code}' -u admin:admin "\
        'http://localhost:4502/path/to/not/exising/node.json'
      ).stdout
    ).to match(/^404$/)
  end
end
