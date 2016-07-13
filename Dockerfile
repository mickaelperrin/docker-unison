FROM alpine:edge
# This is the real maintainer
# MAINTAINER Onni Hakala <onni.hakala@geniem.com>
# MAINTAINER Mickaël Perrin <dev@mickaelperrin.fr>
MAINTAINER Eugen Mayer <eugen.mayer@kontextwork.com>

ARG UNISON_VERSION=2.48.4
ARG FSWATCH_VERSION=1.9.2

RUN apk add --update build-base curl bash supervisor && \
    apk add --update-cache --repository http://dl-4.alpinelinux.org/alpine/edge/testing/ ocaml emacs && \
    curl -L https://github.com/bcpierce00/unison/archive/$UNISON_VERSION.tar.gz | tar zxv -C /tmp && \
    cd /tmp/unison-${UNISON_VERSION} && \
    sed -i -e 's/GLIBC_SUPPORT_INOTIFY 0/GLIBC_SUPPORT_INOTIFY 1/' src/fsmonitor/linux/inotify_stubs.c && \
    make && \
    cp src/unison src/unison-fsmonitor /usr/local/bin && \
    curl -L https://github.com/emcrisostomo/fswatch/releases/download/${FSWATCH_VERSION}/fswatch-${FSWATCH_VERSION}.tar.gz | tar zxv -C /tmp && \
    cd /tmp/fswatch-${FSWATCH_VERSION} && \
    ./configure && make && make install && \
    apk del curl emacs && \
    rm -rf /var/cache/apk/* && \
    rm -rf /tmp/unison-${UNISON_VERSION} && \
    rm -rf /tmp/fswatch-${FSWATCH_VERSION}

# These can be overridden later
ENV TZ="Europe/Helsinki" \
    LANG="C.UTF-8" \
    UNISON_DIR="/data" \
    HOME="/root"

# Install unison server script
ADD entrypoint.sh /entrypoint.sh
RUN chmod +x /entrypoint.sh
ADD unison.sh /unison.sh
RUN chmod +x /unison.sh
ADD fswatch.sh /fswatch.sh
RUN chmod +x /fswatch.sh

RUN mkdir -p /etc/supervisor/conf.d

COPY supervisord.conf /etc/supervisord.conf
COPY supervisor.fswatch.conf /etc/supervisor/conf.d/supervisor.fswatch.conf
COPY supervisor.unison.conf /etc/supervisor/conf.d/supervisor.unison.conf

EXPOSE 5000
ENTRYPOINT ["/entrypoint.sh"]
CMD ["supervisord"]
