RELEASE=$(shell cat Dockerfile| grep chado-schema-builder | grep -o 'download\/.*\/chado-' | sed 's|download/||g;s|/.*||g')

release:
	git tag -s -a -m "Automated release" $(RELEASE)
	git push --all
	git push --tags
