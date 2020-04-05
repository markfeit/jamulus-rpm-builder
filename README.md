# jamulus-rpm-builder

This package builds source and binary RPMs for Jamulus under Fedora
using sources downloaded from GitHub using Vagrant (preferred) or the
local system.


## Vagrant Build (Preferred)

The host system may be any OS that has the following installed:

 * GNU Make
 * Vagrant
 * VirtualBox

The provided `Vagrantfile` provides sane defaults for the build but
can be customized for OS, CPUs and memory by changing the values
assigned at the top of the file.

To build, run `make`.

At the conclusion of the process, all RPMs and SRPMs produced will be in the
current directory.

To remove anything that was produced by the build directly or as a
side effect, run `make clean`.


# Local-System Build

**NOTE:** This procedure will install additional packages on the
system where it is run.  The Makefile's `clean` target will not remove
them.

The host system must be a Jamulus-supported version of Fedora with
the following installed:

 * GNU Make
 * RPMBuild
 * CMake

To build, run `make USE_VAGRANT=false`.  Note that this will invoke
`sudo(8)` to try to install prerequisites and therefore may stop for
interaction with the terminal.  For fully-automated builds, using
Vagrant is recommended.

At the conclusion of the process, all RPMs and SRPMs produced will be in the
current directory.

To remove anything that was produced by the build directly or as a
side effect, run `make USE_VAGRANT=false clean`.
