Building with ci scripts
========================

op-build has several build scripts in the ci/ directory aimed at being used to
help continuous integration environments, as well as specifying build
dependencies as code.

These use Docker containers for the build environment.

It is recommended you use (or send patches so that you can use them) these over
rolling your own scripts.
