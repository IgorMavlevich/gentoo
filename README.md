# gentoo
**Please bear in mind, that this is an early work-in-progress. But it seems to be mostly harmless.**

Scripts for smooth and easy updates on Gentoo systems.
It is possible to use .sh file OR makefile, they are nearly identical, however, makefile allows you to select which stage of it to execute.
Currently, the stages are:
1. **update:** Sync all repos and perform simple update (`emerge --ask --verbose --update @world`)
2. **rebuild:** rebuild new and changed `USE` and preserved libraries, remove unused packages.
3. **clean** dist and pkg
4. **check:** run `revdep-rebuild` and `eix-test-obsolete` to check system state.

### Usage
Run the `autoupdate.sh`
It will not ask you anything.

You may need to run it as root.

Good luck!

-----------------------------------------------------------------------------

`I'm using it on my machine for quite some time and it still didn't blow up.`
