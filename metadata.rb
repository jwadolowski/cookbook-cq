name             'cq'
maintainer       'Jakub Wadolowski'
maintainer_email 'jakub.wadolowski@cognifide.com'
license          'Apache 2.0'
description      'Installs/Configures cq'
long_description IO.read(File.join(File.dirname(__FILE__), 'README.md'))
version          '1.0.0'

depends          'chef-sugar',      '~> 3.1.1'
depends          'java',            '~> 1.31.0'
depends          'ulimit',          '~> 0.3.3'
depends          'cq-unix-toolkit', '= 1.2.0'
