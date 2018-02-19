# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|

  config.vm.box = "fujimakishouten/debian-stretch64"

  # config.vm.box_check_update = false

  config.vm.network "forwarded_port", guest: 8280, host: 8280

  config.vm.synced_folder ".", "/vagrant", id: "vagrant"

  config.vm.provider "virtualbox" do |vb|
    vb.gui = false
    vb.memory = "2048"
  end

  config.vm.provision "shell", privileged: false, inline: <<-SHELL
    wget -O - https://freckles.io | sudo bash -s -- freckelize -v /vagrant/vagrant.yml -r frkl:grav -f /vagrant/
  SHELL
end
