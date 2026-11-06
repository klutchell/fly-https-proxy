FROM alpine:3.21@sha256:87a4361f6c819618a6bafa2ed5228714cb0bb22195d2b49c95eb26799990128a

# hadolint ignore=DL3018
RUN apk add --no-cache tinyproxy

COPY tinyproxy.conf /etc/tinyproxy/tinyproxy.conf
COPY entrypoint.sh /usr/local/bin/

USER nobody

EXPOSE 8888

ENTRYPOINT ["entrypoint.sh"]
