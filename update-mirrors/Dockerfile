FROM bash:alpine3.19

RUN apk --update add git curl coreutils sed gawk dumb-init

RUN git config --global --add safe.directory '*'

ENV WORKING_DIRECTORY="/repos"
ENV RUN_ON_STARTUP="true"

COPY start.sh run.sh /

ENTRYPOINT ["/usr/bin/dumb-init", "--"]
CMD ["/start.sh"]
