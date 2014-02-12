FROM docker-linux/postgres

MAINTAINER Eric Rasche rasche.eric@yandex.ru

# Expose the Postgresql port
EXPOSE 5432

ENV LANG C.UTF-8

ADD ./chado.sh /chado.sh

CMD ["/postgres.sh"]

RUN /chado.sh
