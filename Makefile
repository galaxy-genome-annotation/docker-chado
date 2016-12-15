RELEASE=$(shell cat Dockerfile| grep chado-schema-builder | grep -o 'download\/.*\/chado-' | sed 's|download/||g;s|/.*||g')

run:
	docker run -it -e INSTALL_YEAST_DATA=1 -p 5432:5432 erasche/chado

run_persist:
	docker run -it -e INSTALL_YEAST_DATA=1 -v $(shell pwd)/.pgdata:/var/lib/postgresql/data/ -p 5432:5432 erasche/chado

release:
	git tag -s -a -m "Automated release" $(RELEASE)
	git push --all
	git push --tags
	
