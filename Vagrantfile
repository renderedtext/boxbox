# -*- mode: ruby -*-
# vi: set ft=ruby :

module Helpers
  module_function 

  def mac?
    RbConfig::CONFIG["host_os"] =~ /darwin/
  end
  
  def memory_50_percent
    if mac?
      `sysctl -n hw.memsize`.to_i / 1024 / 1024 / 2
    else
      `grep 'MemTotal' /proc/meminfo | sed -e 's/MemTotal://' -e 's/ kB//'`.to_i / 1024 / 2
    end
  end

  def cpu_count
    if mac?
      `sysctl -n hw.ncpu`.to_i
    else
      `nproc`.to_i
    end
  end
end


Vagrant.configure(2) do |config|
  config.vm.box = "boxbox"

  # make 'boxbox' the hostname of the machine
  config.vm.hostname = "boxbox" 
  
  # I prefer a class A private network that is easy to remember
  config.vm.network "private_network", :ip => "10.20.30.40"

  # make 'boxbox' available in your browser
  config.hostmanager.enabled = true
  config.hostmanager.manage_host = true

  # use ssh key from the host machine
  config.ssh.forward_agent = true

  # allow firefox to be started from the box
  config.ssh.forward_x11 = true

  config.vm.provider "virtualbox" do |vb|
    vb.memory = Helpers.memory_50_percent
    vb.cpus = Helpers.cpu_count
 
    # update time in the machine every 10000 seconds, to avoid issues with bad timestamps
    vb.customize ["guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000]
    
    # hack to make ssh work ¯\_(ツ)_/¯
    # vb.customize ["modifyvm", :id, "--usbxhci", "on"] # Connect USB3 disk
    vb.customize ["modifyvm", :id, "--cableconnected1", "on"]
  end
end
