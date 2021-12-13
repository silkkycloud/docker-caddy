ARG CADDY_VERSION=2.4.6
ARG DATA=/data
ARG CONFIG=/config

####################################################################################################
## Final image
####################################################################################################
FROM alpine:3.15

ARG CADDY_VERSION
ARG DATA
ARG CONFIG

ENV XDG_CONFIG_HOME=${DATA} \
    XDG_DATA_HOME=${CONFIG}

RUN apk add --no-cache \
    ca-certificates \
    tini

ADD https://github.com/caddyserver/caddy/releases/download/v${CADDY_VERSION}/caddy_${CADDY_VERSION}_linux_amd64.tar.gz /tmp/caddy.tar.gz
RUN tar xvfz /tmp/caddy.tar.gz -C /usr/local/bin caddy; \
    rm -rf /tmp/caddy.tar.gz; \
    chmod +x /usr/local/bin/caddy; \
    caddy version

# Create persistent data directories
RUN mkdir -p /etc/caddy \
    && mkdir -p /srv \
    && mkdir -p ${DATA}/caddy \
    && mkdir -p ${CONFIG}/caddy

# Add default config
COPY ./Caddyfile /etc/caddy/Caddyfile
ADD https://raw.githubusercontent.com/caddyserver/dist/master/welcome/index.html /srv/index.html

# Add an unprivileged user and set directory permissions
RUN adduser --disabled-password --gecos "" --no-create-home caddy \
    && chown -R caddy:caddy /usr/local/bin/caddy \
    && chown -R caddy:caddy /etc/caddy \
    && chown -R caddy:caddy /srv \
    && chown -R caddy:caddy ${DATA} \
    && chown -R caddy:caddy ${CONFIG}

ENTRYPOINT ["/sbin/tini", "--", "caddy"]

USER caddy

CMD ["run", "--config", "/etc/caddy/Caddyfile", "--adapter", "caddyfile"]

EXPOSE 3000

STOPSIGNAL SIGTERM

# Image metadata
LABEL org.opencontainers.image.version=${CADDY_VERSION}
LABEL org.opencontainers.image.title=Caddy
LABEL org.opencontainers.image.description="Caddy 2 is a powerful, enterprise-ready, open source web server with automatic HTTPS written in Go"
LABEL org.opencontainers.image.vendor="Silkky.Cloud"
LABEL org.opencontainers.image.licenses=Unlicense
LABEL org.opencontainers.image.source="https://github.com/silkkycloud/docker-caddy"