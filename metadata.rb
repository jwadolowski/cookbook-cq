name             'cq'
maintainer       'Jakub Wadolowski'
maintainer_email 'jakub.wadolowski@cognifide.com'
license          'Apache-2.0'
description      'Installs/Configures cq'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.0'

depends          'java'
depends          'ulimit'
depends          'cq-unix-toolkit', '~> 1.2.0'

source_url       'https://github.com/jwadolowski/cookbook-cq'
issues_url       'https://github.com/jwadolowski/cookbook-cq/issues'
