#! /bin/bash
. /etc/profile
emaint sync --allrepos
emerge -fu @system && emerge -auqv @system || exit 1
emerge -fu @world && emerge -auqv @world || exit 1
emerge -auvqD @system
emerge -fuq --with-bdeps=y @world && emerge -auNUqv --with-bdeps=y @world
emerge -vq @preserved-rebuild
emerge -aq --depclean
revdep-rebuild
eclean-dist -d
eclean-pkg
eix-update
eix-test-obsolete
exit 0
