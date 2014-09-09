# This Makefile can be used to create a debian package for any 
# tag in the Consul git repository on github. A simple
#
#    $ make
#
# will use the latest tag, but any other tag can be specified using
# the VERSION variable, e.g.
#
#    $ make VERSION=0.3.0
#
# Other variables are available: for instance,
#
#    $ make DISTRO=trusty
#
# can be used to change the target distribution (which defaults to
# the one installed on the build machine).
# Please see README.md for a more detailed description.

BASE_DIR  = $(CURDIR)/pkg
SRC_DIR   = $(BASE_DIR)/checkout/src/github.com/hashicorp/consul
DISTRO   ?= $(shell lsb_release -sc)
REVISION ?= 1~$(DISTRO)1~ppa1
MODIFIER ?= 
CHANGE   ?= "New upstream release."
PBUILDER ?= cowbuilder
PBUILDER_BASE ?= $$HOME/pbuilder/$(DISTRO)-base.cow
PPA      ?= 

build: build_src
	mkdir -p $(BASE_DIR)/buildresult
	cd $(BASE_DIR) && sudo $(PBUILDER) --build consul_$(VERSION)-$(REVISION).dsc \
	--basepath=$(PBUILDER_BASE) \
	--buildresult buildresult

build_src: prepare_src 
	cd $(PKG_DIR) && debuild -S

prepare_src: $(SRC_DIR) get_current_version create_upstream_tarball
	rsync -qav --delete debian/ $(PKG_DIR)/debian
	$(eval CREATE = $(shell test -f debian/changelog || echo "--create "))
	test $(CURRENT_VERSION)_ != $(VERSION)-$(REVISION)_ && \
	  debchange -c $(PKG_DIR)/debian/changelog $(CREATE)\
        --package consul \
        --newversion $(VERSION)-$(REVISION) \
        --distribution $(DISTRO) \
        --controlmaint \
        $(CHANGE) || exit 0

create_upstream_tarball: get_new_version
	if [ ! -f pkg/consul_$(VERSION).orig.tar.gz ]; then \
	  rm -rf $(PKG_DIR); \
	  rsync -qav --delete $(BASE_DIR)/checkout/ $(PKG_DIR); \
	  export GOPATH=$(PKG_DIR) && make -C $(PKG_DIR)/src/github.com/hashicorp/consul deps; \
	  make -C $(PKG_DIR)/src/github.com/hashicorp/consul/ui dist; \
	  tar czf pkg/consul_$(VERSION).orig.tar.gz -C $(BASE_DIR) consul-$(VERSION); \
	fi

$(SRC_DIR):
	git clone git@github.com:hashicorp/consul.git $(SRC_DIR)

get_current_version:
	$(eval CURRENT_VERSION = $(shell test -f debian/changelog && \
		dpkg-parsechangelog | grep Version | awk '{print $$2}'))
	@echo "--> Current package version: $(CURRENT_VERSION)"
	
get_new_version:
	cd $(SRC_DIR) && git fetch origin --tags
	$(eval LATEST_TAG = $(shell if [ -z "$(VERSION)" ]; then \
			cd $(SRC_DIR) && git tag | tail -n1; \
		else \
			echo "v$(VERSION)"; \
		fi))
	cd $(SRC_DIR) && git checkout tags/$(LATEST_TAG)
	$(eval VERSION = $(subst v,,$(LATEST_TAG))$(MODIFIER))
	$(eval PKG_DIR = $(BASE_DIR)/consul-$(VERSION))
	@echo "--> New package version: $(VERSION)-$(REVISION)"

clean:
	rm -rf pkg/*

upload: get_new_version
	@if test -z "$(PPA)"; then echo "Usage: make upload PPA=<user>/<ppa>"; exit 1; fi
	dput -f ppa:$(PPA) $(BASE_DIR)/consul_$(VERSION)-$(REVISION)_source.changes
	cp $(BASE_DIR)/consul-$(VERSION)/debian/changelog debian