# Docker Chado Container [![Docker Repository on Quay](https://quay.io/repository/galaxy-genome-annotation/chado/status "Docker Repository on Quay")](https://quay.io/repository/galaxy-genome-annotation/chado) [![DOI](https://zenodo.org/badge/DOI/10.5281/zenodo.3540729.svg)](https://doi.org/10.5281/zenodo.3540729)

Built on top of a standard postgres:16 container, the Chado container provides the Chado schema loaded with all 5 standard ontologies.

## Launching the Container

The Chado container is very simple to start, as simple as a regular postgres
container:

```console
docker run -d --name chado quay.io/galaxy-genome-annotation/chado:latest
```

The Chado schema in this container will not persist across restarts, to allow
for that, supply a volume with `-v` like so:

```console
docker run -d --name chado -v /path/to/storage:/var/lib/postgresql/data/ quay.io/galaxy-genome-annotation/chado
```

The schema and five default ontologies are installed upon launch, if no chado
instance is detected.

## Accessing the Container

If you haven't exposed a port with the `-p/-P` options, you can connect to your chado container via a linked container:

```console
docker run -i -t --link chado:db quay.io/galaxy-genome-annotation/chado bash
root@0069babbd55f:/# psql -h db -U postgres postgres
# Password is postgres
```

## Schema Free Container

If you do not wish to have the schema automatically installed upon launch,
simply set the environment variable `INSTALL_CHADO_SCHEMA` to `0`:

```console
docker run -d --name chado-tools -e INSTALL_CHADO_SCHEMA=0 quay.io/galaxy-genome-annotation/chado
```

This will let you use all the GMOD tools without needing to wait for the chado
schema to install.

## Yeasty Container

If you would like some default yeast data installed for you, you can supply the
environment variable `INSTALL_YEAST_DATA=1`. This requires that you leave `INSTALL_CHADO_SCHEMA=1`:

```console
docker run -d --name chado-yeast -e INSTALL_YEAST_DATA=1 quay.io/galaxy-genome-annotation/chado
```

## Using the Container in `docker-compose.yml`

It is strongly, strongly recommended that you pin your images to a [specific tag](https://quay.io/repository/galaxy-genome-annotation/chado?tab=tags) of this repository. I have unintentionally broken the `:latest` images before.

E.g.

```
image: quay.io/galaxy-genome-annotation/chado:1.31-jenkins61-pg9.5
```

Given that we, as the developers, have no easy way to communicate to you as the end user that breaking changes have been made (and keeping backwards compatability is prohibitve for a small team..., sorry!), it is best to pin and read the changelog before upgrading.

# Changelog

- 2024-02-22
	- @hexylena updated postgres from 9 to 16
	- @hexylena rebuilt with latest CSB data which is still quite old.
- 2021-04-01
	- @mboudet fixed the missing yeast genome
- 2017-02-21
	- Re-arranged image to decrease layers.
	- Added some custom SQL required for postgraphql hacks.
- [sometime recently]
	- changed `PGDATA` to match the current upstream value (`/var/lib/postgresql/data/`) rather than the version specific directory.
