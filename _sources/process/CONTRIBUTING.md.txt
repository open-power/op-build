Contributing to op-build
========================

op-build is the open source build system for OpenPOWER firmware. It assembles
many individual components (only a few of which are OpenPOWER specific) into
a single firmware image. op-build is implemented as a buildroot overlay.

If you haven't already, join us on IRC (#openpower on Freenode) and on
the mailing list ( openpower-firmware@lists.ozlabs.org - subscribe by
going to https://lists.ozlabs.org/listinfo/openpower-firmware )

We use GitHub Issues and Pull Requests for tracking contributions. We
expect participants to adhere to the GitHub Community Guidelines (found
at https://help.github.com/articles/github-community-guidelines/ ).

If you are unable or unwilling to use GitHub, we can accept contributions
via the mailing list.

All contributions should have a Developer Certificate of Origin (see below).

Development Philosophy
----------------------

Our development philosophy is:

1. Don't re-invent the wheel
2. Upstream first

As such, we don't like to carry patches in op-build, we prefer to interact
with upstream projects and get patches accepted there. Where we do need
to patch things locally, we prefer to carry backports from upstream, which
can be removed when we move to more recent upstream.

Development Environment
-----------------------

For working on op-build you will need a reasonably recent Linux distribution.
We aim to have all current major distros be suitable development platforms
(focused on Ubuntu and Fedora, as that's what most developers currently use).

A host GCC of at least 4.9 is recommended (all modern Linux distributions
provide this).

You can build on x86-64, ppc64 or ppc64le, op-build will build appropriate
cross-compilers for you (thanks to the magic of buildroot).

You will need 8-15GB of disk space to do a full build of any one configuration.

Development Process
-------------------

The main source repository is on GitHub. We use GitHub issues and pull requests
as well as a mailing list (https://lists.ozlabs.org/listinfo/openpower-firmware).

We tag a new op-build release roughly every 6 weeks.

We use GitHub milestones: https://github.com/open-power/op-build/milestones

Starting with the v1.15 release, active development occurs against the master
branch. When we're nearing a release, we move the content of the master branch
over to a 'release' branch, ensuring development can continue while the release
is prepared.

We accept pull requests on GitHub: https://github.com/open-power/op-build/pulls

Developer Certificate of Origin
-------------------------------

Contributions to this project should conform to the `Developer Certificate
of Origin` as defined at http://elinux.org/Developer_Certificate_Of_Origin.
Commits to this project need to contain the following line to indicate
the submitter accepts the DCO:
```
Signed-off-by: Your Name <your_email@domain.com>
```
By contributing in this way, you agree to the terms as follows:
```
Developer Certificate of Origin
Version 1.1

Copyright (C) 2004, 2006 The Linux Foundation and its contributors.
660 York Street, Suite 102,
San Francisco, CA 94110 USA

Everyone is permitted to copy and distribute verbatim copies of this
license document, but changing it is not allowed.


Developer's Certificate of Origin 1.1

By making a contribution to this project, I certify that:

(a) The contribution was created in whole or in part by me and I
    have the right to submit it under the open source license
    indicated in the file; or

(b) The contribution is based upon previous work that, to the best
    of my knowledge, is covered under an appropriate open source
    license and I have the right under that license to submit that
    work with modifications, whether created in whole or in part
    by me, under the same open source license (unless I am
    permitted to submit under a different license), as indicated
    in the file; or

(c) The contribution was provided directly to me by some other
    person who certified (a), (b) or (c) and I have not modified
    it.

(d) I understand and agree that this project and the contribution
    are public and that a record of the contribution (including all
    personal information I submit with it, including my sign-off) is
    maintained indefinitely and may be redistributed consistent with
    this project or the open source license(s) involved.
```


