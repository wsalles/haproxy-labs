.PHONY: setup up destroy clean test

# Customizing your output ------------------------------------------------
CODE_CHANGE   = "\\033["
WARNING      := $(shell echo ${CODE_CHANGE}'33;5m')
BOLD_WARNING := $(shell echo ${CODE_CHANGE}'33;1m')
RUNNING      := $(shell echo ${CODE_CHANGE}'32;5m')
SETUP        := $(shell echo ${CODE_CHANGE}'36;4m')
NC           := $(shell echo ${CODE_CHANGE}'0m')

# Targets ----------------------------------------------------------------
check_%:
	$(eval REQ := $(shell which $* ))
	@if [ "${REQ}" = "" ]; then \
		echo "${WARNING}Please, consider doing: \n${BOLD_WARNING}make setup \n \
		      ${NC}${WARNING}\nOr just do it: \n${BOLD_WARNING}pip install $*"; \
		exit 1; \
	 fi ||:

setup: check_vagrant
	@echo "${WARNING}"
	@echo "*** Vagrant and VMWare Fusion 13 Player on Apple M1 Pro ***"
	@echo "You can manually run the commands below:"
	@echo "1: /usr/sbin/softwareupdate --install-rosetta --agree-to-license"
	@echo "2: brew install hashicorp/tap/hashicorp-vagrant"
	@echo "3: brew install --cask vagrant-vmware-utility"
	@echo "4: vagrant plugin install vagrant-vmware-desktop"

up: check_vagrant
	@echo "${RUNNING}"
	@(cd vagrantfiles/nginx && vagrant up --provider vmware_desktop)

destroy: check_vagrant
	@echo "${BOLD_WARNING}"
	@(cd vagrantfiles/nginx && vagrant destroy)

clean: check_vagrant
	@echo "${BOLD_WARNING}"
	@(cd vagrantfiles/nginx && vagrant destroy -f)
	@find . -type d -name ".vagrant" -exec rm -rf {} \;

test: check_ansible
	ansible all -m ping -o