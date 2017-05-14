# gentoo
Scripts for smooth and easy updates on Gentoo systems.
It is possible to use .sh file OR makefile, they are nearly identical, however, makefile allows you to select which stage of it to execute.
Currently, the stages are:
1. **Simple update:** Sync all repos and perform simple update (emerge --ask --verbose --update @world)
2. **Rebuild:** rebuild new and changed USE and preserved libraries, remove unused packages.
3. **Clean** dist and pkg
4. **Check:** run revdep-rebuild and eix-test-obsolete to check system state.  
