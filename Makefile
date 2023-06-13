.PHONY: setup up destroy clean test

# Global Variables
PROVIDER := "vmware_desktop"
VAGRANTFILE_PATH := "vagrantfiles"

# Customizing your output ------------------------------------------------
CODE_CHANGE   = "\\033["
WARNING      := $(shell echo ${CODE_CHANGE}'33;5m')
BOLD_WARNING := $(shell echo ${CODE_CHANGE}'33;1m')
RUNNING      := $(shell echo ${CODE_CHANGE}'32;5m')
SETUP        := $(shell echo ${CODE_CHANGE}'36;4m')
NC           := $(shell echo ${CODE_CHANGE}'0m')

# Targets ----------------------------------------------------------------
check-%:
	$(eval REQ := $(shell which $* ))
	@if [ "${REQ}" = "" ]; then \
		echo "${WARNING}Please, consider doing: \n${BOLD_WARNING}make setup \n \
		      ${NC}${WARNING}\nOr just do it: \n${BOLD_WARNING}pip install $*"; \
		exit 1; \
	 fi ||:

setup: check-vagrant
	@echo "${WARNING}"
	@echo "*** Vagrant and VMWare Fusion 13 Player on Apple M1 Pro ***"
	@echo "You can manually run the commands below:"
	@echo "1: /usr/sbin/softwareupdate --install-rosetta --agree-to-license"
	@echo "2: brew install hashicorp/tap/hashicorp-vagrant"
	@echo "3: brew install --cask vagrant-vmware-utility"
	@echo "4: vagrant plugin install vagrant-vmware-desktop"

# Startup the VMs -------------------------------------------------------------
up-%: check-vagrant
	@echo "${RUNNING}"
	@(cd ${VAGRANTFILE_PATH}/$* && vagrant up --provider ${PROVIDER})

# Shutdown the VMs ------------------------------------------------------------
halt-%: check-vagrant
	@echo "${RUNNING}"
	@(cd ${VAGRANTFILE_PATH}/$* && vagrant halt)

# Restart the VMs -------------------------------------------------------------
reload-%: check-vagrant
	@echo "${BOLD_WARNING}"
	@(cd ${VAGRANTFILE_PATH}/$* && vagrant reload)

# Destroy the VMs -------------------------------------------------------------
destroy-%: check-vagrant
	@echo "${BOLD_WARNING}"
	@(cd ${VAGRANTFILE_PATH}/$* && vagrant destroy)

# Clean the build folder ------------------------------------------------------
clean-%: check-vagrant
	@echo "${BOLD_WARNING}"
	@(cd ${VAGRANTFILE_PATH}/$* && vagrant destroy -f)

# Ansible stuffs --------------------------------------------------------------
test: check-ansible
	ansible all -m ping -o