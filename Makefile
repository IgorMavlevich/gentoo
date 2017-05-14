update:
	emaint sync --allrepos
	emerge -fu @system && emerge -auqv @system || exit 1
	emerge -fu @world && emerge -auqv @world || exit 1
rebuild:
	emerge -auvqD @system
	emerge -auNUqv --with-bdeps=y @world
	emerge -vq @preserved-rebuild
	emerge -aq --depclean
	revdep-rebuild
clean:
	eclean-dist -d
	eclean-pkg
check:
	eix-update
	eix-test-obsolete
