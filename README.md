# Docker Chado Container

[![DOI](https://zenodo.org/badge/10899/erasche/docker-chado.svg)](https://zenodo.org/badge/latestdoi/10899/erasche/docker-chado)

[![Chado](http://dockeri.co/image/erasche/chado)](https://registry.hub.docker.com/u/erasche/chado/)

Built on top of a standard postgres:9.4 container, the Chado container provides
the Chado schema loaded with all 5 standard ontologies.

## Launching the Container

The Chado container is very simple to start, as simple as a regular postgres
container:

```console
docker run -d --name chado erasche/chado
```

The Chado schema in this container will not persist across restarts, to allow
for that, supply a volume with `-v` like so:

```console
docker run -d --name chado -v /path/to/storage:/var/lib/postgresql/9.4/ erasche/chado
```

The schema and five default ontologies are installed upon launch, if no chado
instance is detected.

## Accessing the Container

If you haven't exposed a port with the `-p/-P` options, you can connect to your chado container via a linked container:

```console
docker run -i -t --link chado:db erasche/chado bash
root@0069babbd55f:/# psql -h $DB_PORT_5432_TCP_ADDR -U postgres postgres
# Password is postgres
```

## Schema Free Container

If you do not wish to have the schema automatically installed upon launch,
simply set the environment variable `INSTALL_CHADO_SCHEMA` to `0`:

```console
docker run -d --name chado-tools -e INSTALL_CHADO_SCHEMA=0 erasche/chado
```

This will let you use all the GMOD tools without needing to wait for the chado
schema to install.

## Yeasty Container

If you would like some default yeast data installed for you, you can supply the
environment variable `INSTALL_YEAST_DATA=1`. This requires that you leave `INSTALL_CHADO_SCHEMA=1`:

```console
docker run -d --name chado-yeast -e INSTALL_YEAST_DATA=1 erasche/chado
```
