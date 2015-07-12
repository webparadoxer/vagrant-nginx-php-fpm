# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure(2) do |config|
  config.vm.box = "ubuntu/trusty64"
  config.vm.provision :shell, path: 'bootstrap.bash', run: 'always'
  config.vm.network "forwarded_port", guest: 80, host: 8080
  config.landrush.enabled = true 
  config.vm.hostname = 'dev.vm'
  config.landrush.tld = 'vm'
  config.vm.synced_folder "www/", "/var/www", create : true

end