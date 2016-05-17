#!/bin/bash
mk-build-deps -i -r -t 'apt-get -y' /opt/consul-deb/debian/control
pushd /opt/consul-deb && gbp buildpackage $GIT_BUILDPACKAGE_OPTIONS
cp /tmp/build-area/* /tmp/consul-deb
