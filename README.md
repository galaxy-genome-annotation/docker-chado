# Docker Chado Container

[![Chado](http://dockeri.co/image/erasche/chado)](https://registry.hub.docker.com/u/erasche/chado/)

Built on top of a standard postgres:9.4 container, the Chado container provides
the chado schema loaded with all 5 standard ontologies.

## Accessing the container

The recommended way to access the container is through a linked container, much
like you do with any other application talking to the postgres database

Start the chado container:

```console
docker run -d --name chado erasche/chado
```

Then connect to it through a linked container:

```console
docker run -i -t --link chado:db postgres:9.4 bash
root@0069babbd55f:/# psql -h $DB_PORT_5432_TCP_ADDR -U postgres postgres
# Password is postgres
```
