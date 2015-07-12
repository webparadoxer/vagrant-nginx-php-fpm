# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|

  config.vm.provider "virtualbox" do |v|
    # v.gui = true
    v.memory = 512
    v.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    v.customize ["modifyvm", :id, "--natdnsproxy1", "on"]
  end  
  
  config.vm.box = "ubuntu/trusty64"
  config.vm.provision :shell, path: 'bootstrap.bash', run: 'always'
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.landrush.enabled = true 
  config.vm.hostname = 'dev.vm'
  config.landrush.tld = 'vm'
  config.vm.synced_folder "www/", "/var/www"
end
