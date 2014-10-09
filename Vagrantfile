# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure('2') do |config|
  config.vm.hostname = 'cq-berkshelf'
  config.vm.box = 'opscode_centos-6.5_chef-provisionerless'
  config.vm.box_url = 'http://opscode-vm-bento.s3.amazonaws.com/vagrant/virtualbox/opscode_centos-6.5_chef-provisionerless.box'
  config.vm.network :private_network, ip: '192.168.2.254'

  config.vm.provider 'virtualbox' do |v|
    v.customize ['modifyvm', :id, '--memory', '2048']
    v.customize ['modifyvm', :id, '--cpus', '2']
  end

  config.omnibus.chef_version = :latest
  config.berkshelf.enabled = true

  config.vm.provision :chef_solo do |chef|
    chef.run_list = [
        'recipe[cq::mongo]'
    ]
    chef.log_level = :debug
  end
end
