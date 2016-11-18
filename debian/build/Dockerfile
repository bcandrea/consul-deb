FROM       ubuntu:consul-deb-base
MAINTAINER Andrea Bernardo Ciddio <bcandrea@gmail.com>
ARG        VERSION
ARG        GIT_COMMIT

ENV DEBIAN_FRONTEND=noninteractive \
    GOPATH=/go \
    GIT_COMMIT=${GIT_COMMIT} \
    GIT_DESCRIBE=v${VERSION} \
    GIT_BUILDPACKAGE_OPTIONS=

RUN apt-get update && \
    apt-get install -y equivs ubuntu-dev-tools git-buildpackage software-properties-common && \
    apt-add-repository ppa:gophers/archive && \
    apt-get update

COPY build.sh /build.sh
CMD /bin/bash /build.sh
