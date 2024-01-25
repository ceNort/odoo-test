# -*- mode: ruby -*-
# vi: set ft=ruby :

required_plugins = %w( vagrant-hostsupdater vagrant-env )
required_plugins.each do |plugin|
    exec "vagrant plugin install #{plugin};vagrant #{ARGV.join(" ")}" unless Vagrant.has_plugin? plugin || ARGV[0] == 'plugin'
end

# All Vagrant configuration is done below. The "2" in Vagrant.configure
# configures the configuration version (we support older styles for
# backwards compatibility). Please don't change it unless you know what
# you're doing.
Vagrant.configure("2") do |config|
  # The most common configuration options are documented and commented below.
  # For a complete reference, please see the online documentation at
  # https://docs.vagrantup.com.

  def cpu_is_arm()
    `uname -m` == "arm64" || `/usr/bin/arch -64 sh -c "sysctl -in sysctl.proc_translated"`.strip() == "0"
  end

  if cpu_is_arm()
    config.vm.box = "bento/ubuntu-22.04-arm64"
  else
    config.vm.box = "bento/ubuntu-22.04"
  end

  config.env.enable
  # Check for required .env file
  deployname = ENV['DEPLOY_NAME']
  if deployname == nil
    puts " No .env file found in project root"
    puts " Copy .env.default and rename to .env"
    puts " Change the settings in .env and then re-run the script"
    exit
  end

#   # Check for required certificate files
#   include_dir = "#{__dir__}/script/include/"
#   if(!File.exist?(include_dir + 'gearx.crt') || !File.exist?(include_dir + 'gearx.key'))
#     puts " SSL certificate files not found in #{include_dir}"
#     puts " Put these files in place and re-run the command"
#     puts "   - Certificate file:  gearx.crt"
#     puts "   - Key file:          gearx.key"
#     exit
#   end

  # Create a private network, which allows host-only access to the machine
  # using a specific IP.
  # config.vm.network "private_network", ip: "192.168.33.10"
  config.vm.hostname = "#{deployname}.gearx.com"
  config.vm.network :private_network, ip: ENV['VAGRANT_IP_ADDRESS'], hostname: true
  config.hostsupdater.remove_on_suspend = false


  # Share an additional folder to the guest VM. The first argument is
  # the path on the host to the actual folder. The second argument is
  # the path on the guest to mount the folder. And the optional third
  # argument is a set of non-required options.
  # config.vm.synced_folder "../data", "/vagrant_data"
  projectpath = '/home/' + ENV['SHELL_USER'] + '/' + deployname
  config.vm.synced_folder ".", projectpath

  # Copy git config and ssh key files if found
#   user_files = [".gitconfig", ".gitignore_global", ".ssh/id_rsa", ".ssh/id_rsa.pub"]
#   for file_name in user_files
#     file_path = Dir.home + "/" + file_name
#     if(File.exist?(file_path))
#       config.vm.provision "file", source: file_path, destination: file_name
#     else
#       puts " User file ~/#{file_name} not found.  File will not be copied."
#     end
#   end

  # Add default ssh public key to authorized_keys if found
#   publickey_path = Dir.home + "/" + ".ssh/id_rsa.pub"
#   if(File.exist?(publickey_path))
#     publickey = File.read(publickey_path)
#     config.vm.provision "publickey", type: "shell", privileged: false, inline: <<-SCRIPT
#       echo "#{publickey}" >> /home/vagrant/.ssh/authorized_keys
#     SCRIPT
#   else
#      puts " Public key ~/.ssh/id_rsa.pub not found.  Authorized key will not be added."
#   end

  # Run provisioner shell scripts

#   config.vm.provision "system",   type: "shell",  :inline => "#{projectpath}/script/setup-system"
#   config.vm.provision "vagrant",   type: "shell",  :inline => "#{projectpath}/script/setup-vagrant", privileged: false
#   config.vm.provision "project",  type: "shell",  :inline => "#{projectpath}/script/setup-project", privileged: false

  config.ssh.forward_agent = true

  # Restart Apache after mounting share, because it can fail to start otherwise
#   config.vm.provision "always", type: "shell", :inline => "systemctl restart apache2", run: "always"

  # Provider-specific configuration so you can fine-tune various
  # backing providers for Vagrant. These expose provider-specific options.
  config.vm.provider "virtualbox" do |vb|

    vb.name = "vagrant-#{deployname}"

    # Customize the amount of memory on the VM:
    vb.memory = ENV['VM_MEMORY_MB']

    # There is some information that multiple cpus will slow down the VM due to the way
    # VirtualBox processor scheduling works, but this problem doesn't seem to arise for our
    # use case here. However, do keep an eye out and consider looking into this concept if
    # you experience excessive slowness. Link to problem description below:
    # http://www.mihaimatei.com/virtualbox-performance-issues-multiple-cpu-cores/
    vb.cpus = ENV['VM_CPU_CORES']

    # The guest VM's time can get out of sync with the host, causing a variety or problems
    # This reduces the threshold for Virtualbox to resync the time from the host
    vb.customize [ "guestproperty", "set", :id, "/VirtualBox/GuestAdd/VBoxService/--timesync-set-threshold", 10000 ]

    # Make the host machine act as a DNS resolver for the guest
    vb.customize ["modifyvm", :id, "--natdnshostresolver1", "on"]
    vb.customize ["modifyvm", :id, "--natdnsproxy1", "on"]

    # Fix for bug in bionic64 causing extremely slow initialization and booting
    # https://terryl.in/en/vagrant-up-hangs/#bug-for-bionic64

    vb.customize ["modifyvm", :id, "--uart1", "0x3F8", "4"]
    vb.customize [ "modifyvm", :id, "--uartmode1", "file", File::NULL ]
  end

  config.vm.provider "vmware_desktop" do |vmw|
    vmw.gui = true
    vmw.vmx["displayname"] = "vagrant-#{deployname}"
    vmw.vmx["memsize"] = ENV['VM_MEMORY_MB']
    vmw.vmx["numvcpus"] = ENV['VM_CPU_CORES']
  end

  config.vm.provider "parallels" do |prl|
    prl.name = "vagrant-#{deployname}"
    prl.memory = ENV['VM_MEMORY_MB']
    prl.cpus = ENV['VM_CPU_CORES']
  end

end
