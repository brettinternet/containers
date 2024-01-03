FROM bash:alpine3.19

RUN apk --update add git curl coreutils sed gawk dumb-init

ENV WORKING_DIRECTORY="/repos"

COPY start.sh update.sh /

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/start.sh"]
