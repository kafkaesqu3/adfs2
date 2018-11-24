# -*- mode: ruby -*-
# vi: set ft=ruby :

Vagrant.configure("2") do |config|
  config.vm.define "dc" do |cfg|

    cfg.vm.box = 'detectionlab/windows_2016_virtualbox'
    cfg.vm.hostname = "dc"
    cfg.vm.boot_timeout = 500

    # disables annoying prompt about "Preparing SMB shared folders"
    cfg.vm.synced_folder ".", "/vagrant", disabled: true

    # use the plaintext WinRM transport and force it to use basic authentication.
    # NB this is needed because the default negotiate transport stops working
    #    after the domain controller is installed.
    #    see https://groups.google.com/forum/#!topic/vagrant-up/sZantuCM0q4
    cfg.winrm.transport = :plaintext
    cfg.winrm.basic_auth_only = true

    cfg.vm.communicator = "winrm"
    cfg.vm.network :forwarded_port, guest: 5985, host: 5985, id: "winrm", auto_correct: true
    cfg.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", auto_correct: true
    cfg.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true
    cfg.vm.network :private_network, ip: "192.168.40.2", gateway: "192.168.40.1"

    cfg.vm.provision "file", source: "scripts/", destination: "C:\\scripts"

    cfg.vm.provision "shell", path: "scripts/fix-second-network.ps1", privileged: false, args: "192.168.40.2"
    cfg.vm.provision "shell", path: "scripts/provision.ps1", privileged: false
    cfg.vm.provision "reload"
    cfg.vm.provision "shell", path: "scripts/provision.ps1", privileged: false

    # cfg.vm.provider "vmware_desktop" do |v, override|
    #   v.memory = 2048
    #   v.cpus = 1
    #   v.gui = true
    # end

    cfg.vm.provider "virtualbox" do |vb, override|
      vb.gui = true
      vb.customize ["modifyvm", :id, "--memory", 768]
      vb.customize ["modifyvm", :id, "--cpus", 1]
      vb.customize ["modifyvm", :id, "--vram", "32"]
      vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      vb.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
    end

    # cfg.vm.provider "vmware_esxi" do |esxi|
    #   esxi.esxi_hostname = '192.168.1.8'
    #   esxi.esxi_username = 'root'
    #   esxi.esxi_password = 'file:C:\Users\david\Desktop\keys\vagrant.txt'
    #   esxi.esxi_hostport = 22
    #   esxi.esxi_disk_store = 'datastore1'
    #   esxi.esxi_resource_pool = '/VAGRANT'
    #   esxi.guest_memsize = '2048'
    #   esxi.guest_numvcpus  = '1'
    #   esxi.esxi_virtual_network = ['TESTLAB']
    # end


  end


  config.vm.define "adfs2", autostart: false do |cfg|
    cfg.vm.box = 'detectionlab/windows_2016_virtualbox'
    cfg.vm.hostname = "adfs2"

    # disables annoying prompt about "Preparing SMB shared folders"
    cfg.vm.synced_folder ".", "/vagrant", disabled: true

    cfg.vm.communicator = "winrm"
    cfg.vm.network :forwarded_port, guest: 5985, host: 5985, id: "winrm", auto_correct: true
    cfg.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", auto_correct: true
    cfg.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true
    cfg.vm.network :private_network, ip: "192.168.40.3", gateway: "192.168.40.1", dns: "192.168.40.2"

    cfg.vm.provision "file", source: "scripts/", destination: "C:\\scripts"
    cfg.vm.provision "shell", path: "scripts/fix-second-network.ps1", privileged: false, args: "-ip 192.168.40.3 -dns 192.168.40.2"
    cfg.vm.provision "shell", path: "scripts/provision.ps1", privileged: false
    cfg.vm.provision "reload"
    cfg.vm.provision "shell", path: "scripts/provision.ps1", privileged: false

    cfg.vm.provider "virtualbox" do |vb, override|
      vb.gui = true
      vb.customize ["modifyvm", :id, "--memory", 768]
      vb.customize ["modifyvm", :id, "--cpus", 1]
      vb.customize ["modifyvm", :id, "--vram", "32"]
      vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      vb.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
    end

      cfg.vm.provider "vmware_esxi" do |esxi|
      esxi.esxi_hostname = '192.168.1.8'
      esxi.esxi_username = 'root'
      esxi.esxi_password = 'file:C:\Users\david\Desktop\keys\vagrant.txt'
      esxi.esxi_hostport = 22
      esxi.esxi_disk_store = 'datastore1'
      esxi.esxi_resource_pool = '/VAGRANT'
      esxi.guest_memsize = '2048'
      esxi.guest_numvcpus  = '1'
      esxi.esxi_virtual_network = ['TESTLAB']
    end
  end


  config.vm.define "web", autostart: false do |cfg|
    cfg.vm.box = 'detectionlab/windows_2016_virtualbox'
    cfg.vm.hostname = "web"

    # disables annoying prompt about "Preparing SMB shared folders"
    cfg.vm.synced_folder ".", "/vagrant", disabled: true

    cfg.vm.communicator = "winrm"
    cfg.vm.network :forwarded_port, guest: 5985, host: 5985, id: "winrm", auto_correct: true
    cfg.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", auto_correct: true
    cfg.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true
    cfg.vm.network :forwarded_port, guest: 80, host: 8080, id: "http", auto_correct: true
    cfg.vm.network :private_network, ip: "192.168.40.4", gateway: "192.168.40.1", dns: "192.168.40.2"

    cfg.vm.provision "file", source: "scripts/", destination: "C:\\scripts"
    cfg.vm.provision "shell", path: "scripts/fix-second-network.ps1", privileged: false, args: "-ip 192.168.40.4 -dns 192.168.40.2"
    cfg.vm.provision "shell", path: "scripts/provision.ps1", privileged: false
    cfg.vm.provision "shell", path: "scripts/increase-tcp-num-connections.ps1", privileged: false
    cfg.vm.provision "shell", path: "scripts/install-chocolatey.ps1", privileged: false
    cfg.vm.provision "shell", path: "scripts/install-git.ps1", privileged: false
    cfg.vm.provision "reload"
    cfg.vm.provision "shell", path: "scripts/provision.ps1", privileged: false

    cfg.vm.provider "virtualbox" do |vb, override|
      vb.gui = true
      vb.customize ["modifyvm", :id, "--memory", 2048]
      vb.customize ["modifyvm", :id, "--cpus", 2]
      vb.customize ["modifyvm", :id, "--vram", "32"]
      vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      vb.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
    end

      cfg.vm.provider "vmware_esxi" do |esxi|
      esxi.esxi_hostname = '192.168.1.8'
      esxi.esxi_username = 'root'
      esxi.esxi_password = 'file:C:\Users\david\Desktop\keys\vagrant.txt'
      esxi.esxi_hostport = 22
      esxi.esxi_disk_store = 'datastore1'
      esxi.esxi_resource_pool = '/VAGRANT'
      esxi.guest_memsize = '2048'
      esxi.guest_numvcpus  = '1'
      esxi.esxi_virtual_network = ['TESTLAB']
    end
  end


config.vm.define "ps", autostart: false do |cfg|
    cfg.vm.box = "detectionlab/windows_10_virtualbox"
    cfg.vm.hostname = "ps"

    cfg.vm.communicator = "winrm"
    cfg.vm.network :forwarded_port, guest: 5985, host: 5985, id: "winrm", auto_correct: true
    cfg.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", auto_correct: true
    cfg.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true
    cfg.vm.network :private_network, ip: "192.168.40.9", gateway: "192.168.40.1"

    cfg.vm.provision "shell", path: "scripts/fix-second-network.ps1", privileged: false, args: "-ip 192.168.40.9 -dns 192.168.40.2"
    cfg.vm.provision "shell", path: "scripts/provision.ps1", privileged: false
    cfg.vm.provision "reload"
    cfg.vm.provision "shell", path: "scripts/provision.ps1", privileged: false

    cfg.vm.provider "virtualbox" do |vb, override|
      vb.gui = true
      vb.customize ["modifyvm", :id, "--memory", 768]
      vb.customize ["modifyvm", :id, "--cpus", 1]
      vb.customize ["modifyvm", :id, "--vram", "32"]
      vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      vb.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
    end
end

  config.vm.define "ts", autostart: false do |cfg|
    cfg.vm.box = 'detectionlab/windows_10_virtualbox'
    cfg.vm.hostname = "ts"

    cfg.vm.communicator = "winrm"
    cfg.vm.network :forwarded_port, guest: 5985, host: 5985, id: "winrm", auto_correct: true
    cfg.vm.network :forwarded_port, guest: 22, host: 2222, id: "ssh", auto_correct: true
    cfg.vm.network :forwarded_port, guest: 3389, host: 3389, id: "rdp", auto_correct: true
    cfg.vm.network :private_network, ip: "192.168.40.15", gateway: "192.168.40.1"

    cfg.vm.provision "shell", path: "scripts/fix-second-network.ps1", privileged: false, args: "-ip 192.168.40.15 -dns 192.168.40.2"
    cfg.vm.provision "shell", path: "scripts/provision.ps1", privileged: false
    cfg.vm.provision "reload"
    cfg.vm.provision "shell", path: "scripts/provision.ps1", privileged: false
    cfg.vm.provision "reload"

    cfg.vm.provider "virtualbox" do |vb, override|
      vb.gui = true
      vb.customize ["modifyvm", :id, "--memory", 768]
      vb.customize ["modifyvm", :id, "--cpus", 1]
      vb.customize ["modifyvm", :id, "--vram", "32"]
      vb.customize ["modifyvm", :id, "--clipboard", "bidirectional"]
      vb.customize ["setextradata", "global", "GUI/SuppressMessages", "all" ]
    end

    cfg.vm.provider "vmware_esxi" do |esxi|
      esxi.esxi_hostname = '192.168.1.8'
      esxi.esxi_username = 'root'
      esxi.esxi_password = 'file:C:\Users\david\Desktop\keys\vagrant.txt'
      esxi.esxi_hostport = 22
      esxi.esxi_disk_store = 'datastore1'
      esxi.esxi_resource_pool = '/VAGRANT'
      esxi.guest_memsize = '2048'
      esxi.guest_numvcpus  = '1'
      esxi.esxi_virtual_network = ['TESTLAB']
    end
    
  end
end
