PKGDIR      := $(CURDIR)/../..
DISTRO      := $(shell head -n1 $(PKGDIR)/debian/changelog | cut -d ' ' -f 3 | tr -d ';')
VERSION     := $(shell head -n1 $(PKGDIR)/debian/changelog | cut -d ' ' -f 2 | sed -E 's/[^0-9.]*([0-9.]+)-.+/\1/')
DEB_VERSION := $(shell head -n1 $(PKGDIR)/debian/changelog | cut -d ' ' -f 2 | sed -E 's/[()]//g')

PPA            ?=
CONTAINER_CMD  ?=
CONTAINER_OPTS ?=

all: buildpackage

version:
	@echo 'Building consul-$(DEB_VERSION)'
	@echo 'Upstream version: $(VERSION)'
	@echo 'Distribution: $(DISTRO)'

image: version tools
	docker pull ubuntu:$(DISTRO)
	docker tag ubuntu:$(DISTRO) ubuntu:consul-deb-base
	sh -c "docker build -t ubuntu:$(DISTRO)-consul-deb \
		--build-arg VERSION=$(VERSION) \
		--build-arg GIT_COMMIT=$(shell git rev-parse --short v$(VERSION)) \
		$(CURDIR)"
	docker rmi ubuntu:consul-deb-base

buildpackage: image
	$(MAKE) runcontainer

buildsource: image gpgkey
	$(MAKE) runcontainer \
					CONTAINER_OPTS="-e GIT_BUILDPACKAGE_OPTIONS='--git-builder=debuild -eGOPATH -eGIT_IMPORT -eGIT_DESCRIBE -eGIT_COMMIT -eBUILD_TAGS -i -I -S -sa'"

clean:
	@sh -c 'dangling=$$(docker images -qf dangling=true); [ -n "$$dangling" ] && docker rmi $$dangling || true'
	rm -rf /tmp/consul-deb

tools:
	@echo Checking availability of tools:
	@sh -c 'which docker || (echo "Please install docker"; false)'
	@sh -c 'which git    || (echo "Please install git"; false)'
	@sh -c 'which gpg    || (echo "Please install gpg"; false)'

login: version tools
	$(MAKE) runcontainer CONTAINER_CMD=bash

upload: version tools
	@sh -c 'test -n "$(PPA)" || (echo "Please specify a PPA name, e.g. make upload PPA=myuser/myppa"; false)'
	$(MAKE) runcontainer CONTAINER_CMD="dput -f ppa:$(PPA) /tmp/consul-deb/consul_$(DEB_VERSION)_source.changes" && \
		git tag v$(shell echo $(DEB_VERSION) | tr '~' '_' )

runcontainer:
	mkdir -p /tmp/consul-deb
	docker run -i --rm \
		-v ~/.devscripts:/root/.devscripts \
		-v ~/.gnupg:/root/.gnupg \
		-v $(PKGDIR):/opt/consul-deb:ro \
		-v /tmp/consul-deb:/tmp/consul-deb \
		$(CONTAINER_OPTS) \
		ubuntu:$(DISTRO)-consul-deb $(CONTAINER_CMD)

gpgkey: ~/.devscripts
	@sh -c 'test -n "$$DEBSIGN_KEYID" || (echo "Please export DEBSIGN_KEYID in ~/.devscripts"; false)'
	@sh -c '. ~/.devscripts; gpg --list-pub "$$DEBSIGN_KEYID"'

~/.devscripts:
	@sh -c 'test -f ~/.devscripts || (echo "Please export DEBSIGN_KEYID in ~/.devscripts"; false)'

.PHONY: all version image buildpackage buildsource clean tools login gpgkey runcontainer upload
