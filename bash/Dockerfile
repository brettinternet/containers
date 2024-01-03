FROM bash:latest

RUN apk --update add git curl jq dumb-init

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
