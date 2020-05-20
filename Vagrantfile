# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  os = "bento/ubuntu-18.04"
  net_ip = "192.168.50"

  config.vm.define :master, primary: true do |master_config|
    master_config.vm.provider "virtualbox" do |vb|
        vb.memory = "2048"
        vb.cpus = 1
        vb.name = "master"
    end

    master_config.vm.box = "#{os}"
    master_config.vm.host_name = 'saltmaster.local'
    master_config.vm.network "private_network", ip: "#{net_ip}.10"
    master_config.vm.synced_folder "salt/", "/srv/salt"
    master_config.vm.synced_folder "pillar/", "/srv/pillar"

    master_config.vm.provision :shell do |shell|
        shell.inline = "set -ex; \
          apt-get -y install git zsh; \
          sudo chsh -s /bin/zsh vagrant; \
          git clone git://github.com/robbyrussell/oh-my-zsh.git /home/vagrant/.oh-my-zsh; \
          cp /home/vagrant/.oh-my-zsh/templates/zshrc.zsh-template /home/vagrant/.zshrc"
    end

    master_config.vm.provision :salt do |salt|
      salt.master_config = "etc/master"
      salt.master_key = "keys/master_minion.pem"
      salt.master_pub = "keys/master_minion.pub"
      salt.minion_key = "keys/master_minion.pem"
      salt.minion_pub = "keys/master_minion.pub"
      salt.seed_master = {
                          "minion1" => "keys/minion1.pub",
                          "minion2" => "keys/minion2.pub"
                         }

      salt.install_type = "stable"
      salt.install_master = true
      salt.no_minion = true
      salt.verbose = true
      salt.colorize = true
      salt.bootstrap_options = "-P -c /tmp"
    end
  end


  [
    ["minion1",    "#{net_ip}.11",    "1024",    os ],
    ["minion2",    "#{net_ip}.12",    "1024",    os ],
  ].each do |vmname,ip,mem,os|
    config.vm.define "#{vmname}" do |minion_config|
      minion_config.vm.provider "virtualbox" do |vb|
          vb.memory = "#{mem}"
          vb.cpus = 1
          vb.name = "#{vmname}"
      end

      minion_config.vm.box = "#{os}"
      minion_config.vm.hostname = "#{vmname}"
      minion_config.vm.network "private_network", ip: "#{ip}"

      minion_config.vm.provision :shell do |shell|
        shell.inline = "set -ex; \
          apt-get -y install git zsh; \
          sudo chsh -s /bin/zsh vagrant; \
          git clone git://github.com/robbyrussell/oh-my-zsh.git /home/vagrant/.oh-my-zsh; \
          cp /home/vagrant/.oh-my-zsh/templates/zshrc.zsh-template /home/vagrant/.zshrc"
      end

      minion_config.vm.provision :salt do |salt|
        salt.minion_config = "etc/#{vmname}"
        salt.minion_key = "keys/#{vmname}.pem"
        salt.minion_pub = "keys/#{vmname}.pub"
        salt.install_type = "stable"
        salt.verbose = true
        salt.colorize = true
        salt.bootstrap_options = "-P -c /tmp"
      end
    end
  end
end
