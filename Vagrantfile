# -*- mode: ruby -*-
# vi: set ft=ruby :

# Vagrantfile API/syntax version. Don't touch unless you know what you're doing!
VAGRANTFILE_API_VERSION = "2"

# Box metadata
BOX_NAME    = "starboard/ubuntu-arm64-20.04.5" # ARM64 Box for Apple M1/M2 users
BOX_VERSION = "20221120.20.40.0"

nodes = {
  nginx: {
    numbers: 1,
    hostname_prefix: "ubuntu-nginx-",
    cpu: 1,
    mem: 512,
    src_code: "scripts/nginx",
  },
  haproxy: {
    numbers: 1,
    hostname_prefix: "ubuntu-haproxy-",
    cpu: 1,
    mem: 512,
    src_code: "scripts/haproxy",
  },
}

# UI object for printing information
ui = Vagrant::UI::Prefixed.new(Vagrant::UI::Colored.new, "vagrant")

Vagrant.configure(VAGRANTFILE_API_VERSION) do |config|
  (1..nodes[:nginx][:numbers]).each do |i|
    ui.info "Creating VM: #{"#{nodes[:nginx][:hostname_prefix]}#{i}"}"
    config.vm.define "#{nodes[:nginx][:hostname_prefix]}#{i}" do |nginx|
      nginx.vm.box = BOX_NAME
      nginx.vm.box_download_insecure = true
      nginx.vm.hostname = "#{nodes[:nginx][:hostname_prefix]}#{i}"
      nginx.vm.network :private_network, ip: "172.10.10.10#{i}"
      nginx.ssh.insert_key = false
      nginx.ssh.private_key_path = ['~/.vagrant.d/insecure_private_key', '~/.ssh/id_rsa']
      nginx.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/authorized_keys"
      nginx.vm.provision "shell", path: "#{nodes[:nginx][:src_code]}/install.sh"
      nginx.vm.provider "vmware_desktop" do |v|
        v.gui = false
        v.ssh_info_public = true
        v.allowlist_verified = true
        v.linked_clone = false
        v.memory = "#{nodes[:nginx][:mem]}"
        v.cpus = "#{nodes[:nginx][:cpu]}"
        v.vmx["ethernet0.pcislotnumber"] = "160"
      end
      nginx.vm.provision "shell", inline: "echo '[NGINX] INSTALLER: Installation complete and ready to use!'"
    end
  end

  (1..nodes[:haproxy][:numbers]).each do |i|
    ui.info "Creating VM: #{"#{nodes[:haproxy][:hostname_prefix]}#{i}"}"
    config.vm.define "#{nodes[:haproxy][:hostname_prefix]}#{i}" do |haproxy|
      haproxy.vm.box = BOX_NAME
      haproxy.vm.box_download_insecure = true
      haproxy.vm.hostname = "#{nodes[:haproxy][:hostname_prefix]}#{i}"
      haproxy.vm.network :private_network, ip: "172.10.10.12#{i}"
      haproxy.ssh.insert_key = false
      haproxy.ssh.private_key_path = ['~/.vagrant.d/insecure_private_key', '~/.ssh/id_rsa']
      haproxy.vm.provision "file", source: "~/.ssh/id_rsa.pub", destination: "~/.ssh/authorized_keys"
      haproxy.vm.provision "file", source: "#{nodes[:haproxy][:src_code]}/haproxy.service", destination: "/tmp/haproxy.service"
      haproxy.vm.provision "file", source: "#{nodes[:haproxy][:src_code]}/haproxy.cfg", destination: "/tmp/haproxy.cfg"
      haproxy.vm.provision "file", source: "#{nodes[:haproxy][:src_code]}/keepalived.conf", destination: "/tmp/keepalived.conf"
      haproxy.vm.provision "shell", path: "#{nodes[:haproxy][:src_code]}/disable-selinux.sh"
      haproxy.vm.provision "shell", path: "#{nodes[:haproxy][:src_code]}/before_script.sh"
      haproxy.vm.provision "shell", path: "#{nodes[:haproxy][:src_code]}/keepalived.sh"
      haproxy.vm.provision "shell", path: "#{nodes[:haproxy][:src_code]}/haproxy.sh"
      haproxy.vm.provider "vmware_desktop" do |v|
        v.gui = false
        v.ssh_info_public = true
        v.allowlist_verified = true
        v.linked_clone = false
        v.memory = "#{nodes[:haproxy][:mem]}"
        v.cpus = "#{nodes[:haproxy][:cpu]}"
      end
      haproxy.vm.provision "shell", inline: "echo '[HA PROXY] INSTALLER: Installation complete and ready to use!'"
    end
  end
end
