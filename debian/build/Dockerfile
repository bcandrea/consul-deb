FROM       ubuntu:consul-deb-base
MAINTAINER Andrea Bernardo Ciddio <bcandrea@gmail.com>
ARG        VERSION
ARG        GIT_COMMIT

ENV DEBIAN_FRONTEND=noninteractive \
    GOPATH=/go \
    GIT_COMMIT=${GIT_COMMIT} \
    GIT_DESCRIBE=v${VERSION} \
    GIT_BUILDPACKAGE_OPTIONS=

RUN apt-get update && apt-get install -y equivs ubuntu-dev-tools git-buildpackage

COPY build.sh /build.sh

RUN mkdir -p /go/src/github.com/hashicorp /go/bin /go/pkg /output && \
    ln -sf /tmp/consul-deb/consul-${VERSION} /go/src/github.com/hashicorp/consul

CMD /bin/bash /build.sh
