# A debian package for Consul

## Overview

This project can be used to create a debian package for any tag in the
[Consul](http://www.consul.io) git repository on github
(https://github.com/hashicorp/consul). A simple

    $ make

will package the latest tag, but any other version tag can be specified using
the `VERSION` variable, e.g.

    $ make VERSION=0.3.0

Ubuntu packages built regularly with this Makefile are available at
[this Launchpad PPA](https://launchpad.net/~bcandrea/+archive/ubuntu/consul). To
install the latest Consul packages on your Ubuntu system you just need to add the
repository and update the local sources:

    $ sudo apt-add-repository ppa:bcandrea/consul
    $ sudo apt-get update
    $ sudo apt-get install consul consul-web-ui


## Usage

The simplest usage of the Makefile is, of course,

    $ make

It has the (perhaps obvious) effect of cloning the consul git repo locally, checking
out the latest version tag, and building a binary .deb package out of it. Two packages,
actually: the main `consul` package containing the binary and the `consul-web-ui` package
providing the web interface to the cluster of nodes.

The available targets are:

* `build`: The default target. Builds binary and source packages.
* `build_src`: Builds a source debian package that can be used for uploads to Launchpad.
* `upload`: Uploads the source package to Launchpad. Requires setting the `PPA` variable on
            the command line (e.g. `make upload PPA=myuser/myppa`).
* `clean`: Removes everything under `pkg`.

As already mentioned, the `VERSION` variable is the easiest way to go back in time
and produce a package for a different tag:

    $ make VERSION=0.3.0

Several other variables are available: for instance,

    $ make CHANGE="No-change build for Trusty." DISTRO=trusty

can be used to change the target distribution (which defaults to
the one installed on the build machine), using a custom changelog message.
Here is the complete list:


* `DISTRO`: Select the target codename for the build (e.g. precise, natty).
            Defaults to the codename of the build machine.
* `VERSION`: Select which release tag to use as a base for the upstream
             tarball. If not specified, the latest tag will be used.
* `MODIFIER`: An optional modifier to append to the selected upstream version (e.g.
              "~beta1"). Not needed in most circumstances.
* `REVISION`: The debian revision to append to the upstream version. Defaults
              to `1~$(DISTRO)1~ppa1`.
* `CHANGE`: The message to use in the debian/changelog file for this package.
            Defaults to "New upstream release".
* `PBUILDER`: Allows to select an executable different from cowbuilder to
              produce the binary package.
* `PBUILDER_BASE`: Allows to specify a custom path for the cowbuilder/pbuilder base
                   image. Defaults to `$HOME/pbuilder/$(DISTRO)-base.cow`.
* `PPA`: Variable needed when uploading the package to Launchpad.
         Example: `make upload PPA=myuser/myppa`.

## Building for multiple distros

Uploads to Launchpad only include the upstream tarball once. This means that, when
building the package for multiple distros, you should never run `make clean` between `make`
commands. That would delete and recreate the upstream tarball, making subsequent Launchpad uploads fail.

For example, the following sequence might be used to build the latest version for precise, trusty and
utopic:

    make clean
    make DISTRO=precise
    make DISTRO=trusty CHANGE="No-change build for Trusty."
    make DISTRO=utopic CHANGE="No-change build for Utopic."
    make upload DISTRO=precise PPA=myuser/myppa
    make upload DISTRO=trusty PPA=myuser/myppa
    make upload DISTRO=utopic PPA=myuser/myppa

## Prerequisites

The build machine must meet a set of requirements to be able to
run the Makefile. In particular it needs:

* a suitable environment for building debian packages (pbuilder/cowbuilder)
* a relatively recent Ruby runtime, with the `sass` and `uglifier` gems installed

Without trying to cover all the possible cases, I will describe the steps needed on a
(quite old) Ubuntu 12.04 system.

### Setting up cowbuilder

First install the packages:

    $ sudo apt-get install cowbuilder ubuntu-dev-tools

Then create the base folder which will be used to setup the chrooted
environment in which the package will be built:

    $ mkdir -p ~/pbuilder/
    $ sudo cowbuilder --create --distribution precise \
                      --components "main restricted universe multiverse" \
                      --basepath=$HOME/pbuilder/precise-base.cow

If you have more than one PGP key in your local keyring (I do),
you may also want to specify which one to use when signing
packages. Just list your keys with `gpg --list-keys`, and copy
the key id to `/etc/devscripts.conf` under the debsign stanza:

    DEBSIGN_KEYID=FDCCCD6E

Another problem to avoid: the personal package builders cowbuilder and
pbuilder must be allowed to preserve the environment
when called using `sudo`. Create the file `/etc/sudoers.d/pbuilders` using the command

    $ sudo visudo -f /etc/sudoers.d/pbuilders

and put the following two lines into it:

    Cmnd_Alias PBUILDERS = /usr/sbin/pbuilder, /usr/sbin/cowbuilder
    ALL ALL=(ALL) SETENV: PBUILDERS

The last issue is the dependency from a relatively recent version of Go. This is
not a problem on Trusty (14.04), but for Precise the package needs to be fetched from
a PPA. This can be done easily by logging into the cowbuilder image with

    $ sudo cowbuilder --login --basepath ~/pbuilder/precise-base.cow/ --save-after-login

and adding to the file `/etc/apt/sources.list` the following line:

    deb http://ppa.launchpad.net/bcandrea/backports/ubuntu precise main

The package index then needs to be updated with the command

    # apt-get update

The `--save-after-login` option will ensure our change will be committed to
the cowbuilder image after logging off.

### Setting up Ruby

This should be as simple as

    $ sudo apt-get install ruby1.9.1
    $ sudo gem install sass uglifier

You can of course use rbenv/rvm/anything else. YMMV.

