name             'cq'
maintainer       'Jakub Wadolowski'
maintainer_email 'jakub.wadolowski@cognifide.com'
license          'Apache 2.0'
description      'Installs/Configures cq'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.0'

depends          'chef-sugar', '~> 2.4.1'
depends          'java', '= 1.28.0'
depends          'ulimit', '= 0.3.2'
depends          'cq-unix-toolkit', '= 1.2.0'
