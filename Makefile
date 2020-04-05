#
# Makefile for darktable RPM Builder
#

# Customize the following to taste:

NAME    := jamulus
VERSION := 3.4.5

# Set this to 'false' to build locally
#
# NB: The build process invokes sudo(8), and running it on your own
# account may result in a stop to interact with the terminal.  For
# fully-automated builds, using Vagrant is recommended.
#
USE_VAGRANT := true

# Set this to 'true' to keep the VM around post-build, requiring a
# manual build of the 'clean' target to get rid of it.
KEEP_VM := false

# Set this to 'false' to skip trying to install the prerequisites.
INSTALL_PREREQS := true


# NO USER-SERVICEABLE PARTS BELOW THIS LINE.


ifeq ($(USE_VAGRANT),true)
  default: build-vagrant
else
  default: build-local
endif


VERSION_UNDER=$(shell echo $(VERSION) | tr . _)


TARBALL := $(NAME)-$(VERSION).tar.gz
$(TARBALL):
	rm -rf "$@"
	curl --location -s -o "$@" "https://github.com/corrados/jamulus/archive/r$(VERSION_UNDER).tar.gz"
TO_CLEAN += $(TARBALL)


SPEC := $(NAME).spec
$(SPEC): $(SPEC).raw
	sed -e 's/__VERSION__/$(VERSION)/g' $< > $@
TO_CLEAN += $(SPEC)


# This needs to be an absolute because it's used in invoking rpmbuild.
BUILD_DIR := $(PWD)/rpmbuild

$(BUILD_DIR): $(TARBALL) $(SPEC)
	rm -rf $@
	mkdir -p \
		$@/BUILD \
		$@/BUILDROOT \
		$@/RPMS \
		$@/SOURCES \
		$@/SPECS \
		$@/SRPMS
	cp $(SPEC) $@/SPECS
	cp $(TARBALL) $@/SOURCES
TO_CLEAN += $(BUILD_DIR)



build-local: $(BUILD_DIR) $(SPEC) $(TARBALL)
ifeq ($(INSTALL_PREREQS),true)
#
#	Find and install the prerequisites
#
	rpmspec -P "$(SPEC)" \
	| egrep -e "^(Build)?Requires:" \
	| awk '{ print $$2 }' \
	| sudo xargs yum -y install
endif  # INSTALL_PREREQS
#
# 	Build the RPM
#
	set -o pipefail \
		&& HOME=$(shell pwd) \
		rpmbuild -ba \
		--define "_topdir $(BUILD_DIR)" \
                $(SPEC) 2>&1 \
	        | tee build.log
#
#	Copy out the results
#
	cp $(BUILD_DIR)/SRPMS/*.rpm .
	cp $(BUILD_DIR)/RPMS/*/*.rpm .
TO_CLEAN += build.log *.rpm



# By-products
TO_CLEAN += .ccache




#
# Vagrant Targets
#

ifeq ($(USE_VAGRANT),true)


# This can only be done after a vagrant up
SSH_CONFIG := ssh.config
$(SSH_CONFIG):
	vagrant ssh-config > $@
SCP := scp -F $(SSH_CONFIG) -q
TO_CLEAN += $(SSH_CONFIG)



VAGRANT_DIR := /vagrant
build-vagrant: $(TARBALL)
	vagrant up
	$(MAKE) $(SSH_CONFIG)
	vagrant ssh -c "cd $(VAGRANT_DIR) && make build-local"
	$(SCP) "default:/$(VAGRANT_DIR)/*.rpm" .
	$(SCP) "default:/$(VAGRANT_DIR)/build.log" .
ifneq ($(KEEP_VM),true)
	vagrant destroy -f
endif
TO_CLEAN += build.log *.rpm


ssh:
	vagrant ssh

clean::
	vagrant destroy -f
TO_CLEAN += .vagrant


endif  # $(USE_VAGRANT)



#
# Everything else
#

clean::
	rm -rf $(TO_CLEAN) *~
