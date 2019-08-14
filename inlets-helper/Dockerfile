FROM alexellis2/inlets:2.2.0

USER root

ARG INL_REMOTE_URI
ENV INL_REMOTE_URI ${INL_REMOTE_URI}

COPY ./scripts/inlets-helper.sh /home/app

RUN chown -R app /home/app \
  && chmod +x /home/app/inlets-helper.sh

USER app
WORKDIR /home/app

ENTRYPOINT ["/home/app/inlets-helper.sh"]
