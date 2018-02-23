FROM freckles/debian:stretch

ARG GRAV_UID=1000
ARG GRAV_GID=1000

RUN groupadd -g "${GRAV_GID}" grav
RUN useradd -g grav -u "${GRAV_UID}" -ms /bin/bash grav

COPY --chown=grav:grav . /var/lib/freckles/website

RUN  /root/.local/bin/frecklecute use-freckles-version git

RUN  /root/.local/bin/freckelize -v /var/lib/freckles/website/docker.yml -r frkl:grav -f /var/lib/freckles/website

CMD ["/opt/supervisord/bin/supervisord -c /etc/supervisor/supervisord.conf"]
