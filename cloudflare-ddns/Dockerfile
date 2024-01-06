FROM bash:alpine3.19

RUN apk --update add curl coreutils dumb-init

ENV RUN_ON_STARTUP="true"

COPY start.sh run.sh /

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/start.sh"]
