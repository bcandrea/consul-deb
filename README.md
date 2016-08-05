# A debian package for Consul
[![Build Status](https://semaphoreci.com/api/v1/bcandrea/consul-deb/branches/debian/badge.svg)](https://semaphoreci.com/bcandrea/consul-deb)

## Overview

This project can be used to create a debian package for the
[Consul](http://www.consul.io) git repository on github
(https://github.com/hashicorp/consul). The package is produced following the
standard layout of [`git-buildpackage`
projects](http://honk.sigxcpu.org/projects/git-buildpackage/manual-html/gbp.html),
except for the name of the debian branch (which in this case is `debian` instead
of `master`), and uses [Docker](https://www.docker.com) to ensure isolated,
repeatable builds.

To build the package, checkout the `debian` branch and run `make`:

    $ git checkout debian
    $ make -C debian/build

The command only depends on the presence of git and Docker; it creates a new
image locally and executes `gbp buildpackage` in it. Results will be saved to
`/tmp/consul-deb`.

    $ ls /tmp/consul-deb
    consul_0.6.4-1~trusty1~ppa1.debian.tar.gz  consul_0.6.4-1~trusty1~ppa1.dsc
    consul_0.6.4-1~trusty1~ppa1_source.build   consul_0.6.4-1~trusty1~ppa1_source.changes
    consul_0.6.4.orig.tar.gz

This repository is tagged with upstream versions (e.g., `v0.6.4`), which point
to the commits from the `upstream` branch, and Debian package versions (e.g.
`v0.6.4-1_trusty1_ppa1`). Since the tilde (`~`) character is not legal in git
tags, Debian revision tags use underscore instead (the tag in the example points
to version `0.6.4-1~trusty1~ppa1`). You can build a specific version of the
package by checking out the relevant tag:

    $ # ==> build version 0.6.4-1~trusty1~ppa1
    $ git checkout v0.6.4-1_trusty1_ppa1
    $ make -C debian/build

Ubuntu packages built regularly with this Makefile are available at
[this Launchpad PPA](https://launchpad.net/~bcandrea/+archive/ubuntu/consul). To
install the latest Consul packages on your Ubuntu system you just need to add the
repository and update the local sources:

    $ sudo apt-add-repository ppa:bcandrea/consul
    $ sudo apt-get update
    $ sudo apt-get install consul consul-web-ui

## Usage

The available targets in the makefile are:

* `buildpackage`: The default target. Builds binary and source packages.
* `buildsource`: Builds a source debian package that can be used for uploads to
  Launchpad.
* `upload`: Uploads the source package to Launchpad. Requires setting the `PPA`
  variable on the command line (e.g. `make -C debian/build upload PPA=myuser/myppa`).
* `clean`: Removes intermediate Docker images and the `/tmp/consul-deb` directory.

## Prerequisites

The build machine just needs a working Docker installation (and, of course, git)
to be able to run the makefile (e.g. it can be a Mac). When building a source
package to upload to a PPA you will also need a GPG key.

### Setting up GPG

First make sure GPG is installed and working:

    $ gpg --list-sec

The output should contain a list of valid GPG signing keys. For the makefile to
work, a file named `~/.devscripts` must be created with at least the following
variable:

    DEBSIGN_KEYID=<gpg key id>

(you can specify other values, e.g. `DEBFULLNAME` and `DEBEMAIL`).
