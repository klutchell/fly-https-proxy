FROM alpine:3.24@sha256:660e0827bd401543d81323d4886abbd08fda0fe3ba84337837d0b11a67251283

# hadolint ignore=DL3018
RUN apk add --no-cache tinyproxy

COPY tinyproxy.conf /etc/tinyproxy/tinyproxy.conf
COPY entrypoint.sh /usr/local/bin/

USER nobody

EXPOSE 8888

ENTRYPOINT ["entrypoint.sh"]
