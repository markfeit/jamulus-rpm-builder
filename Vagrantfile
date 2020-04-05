#
# Vagrantfile for Darktable RPM Builder
#

# Configure the following to taste:

# These have been tested and work.
box = "fedora/31-cloud-base"
# box = "fedora/30-cloud-base"

# These do not work but are here for later development.
# box = "centos/7"
# box = "centos/8"


# Guest processors.  Nil will use all but one of the hosts's cores.
vm_cpus = nil

# Guest memory.  Nil will use a sane default (2 GiB)
vm_memory = nil


# NO USER-SERVICEABLE PARTS BELOW THIS LINE.


require 'etc'


Vagrant.configure("2") do |config|

  config.vm.box = box
  
  # Enable X forwarding for testing
  config.ssh.forward_agent = true
  config.ssh.forward_x11 = true

  # Set up CPUs and RAM

  if vm_cpus.nil?
    vm_cpus = Etc.nprocessors - 1
    if vm_cpus < 1
      vm_cpus = 1
    end
  end

  if vm_memory.nil?
    vm_memory = 2048
  end

  config.vm.provider "virtualbox" do |vbox|
    vbox.cpus = vm_cpus    
    vbox.memory = vm_memory
  end

  # Force a regular rsync'd folder so vboxsf's quirks aren't a factor
  config.vm.synced_folder ".", "/vagrant",
                          type: "rsync",
                          rsync__exclude: [ ".git/", ".vagrant/" ]
 
  # Install and enable repos on various RHEL derivatives
  
  if config.vm.box.start_with?("rhel/", "centos/")
    config.vm.provision "shell", inline: <<-SHELL

      yum -y install epel-release

      for REPO in PowerTools centosplus
      do
        yum -q repolist all \
        | awk '{ print $1 }' \
        | fgrep -xq "${REPO}" \
        && yum-config-manager --enable "${REPO}"
      done

    SHELL
  end


  # Update and set up prerequisites
  config.vm.provision "shell", inline: <<-SHELL

    yum -y update

    yum -y install \
        make \
        rpm-build


  SHELL
end


# -*- mode: ruby -*-
# vi: set ft=ruby :
