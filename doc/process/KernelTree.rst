op-build Linux Kernel
=====================

The skiroot/Petitboot kernel is currently based on the 5.1 series.

Submitting a patch
------------------

If you require a patch added to the firmware, follow these steps:

1. Submit your patch upstream. It doesn’t need to be upstream, but it
   should be on it’s way
2. Send a pull request or a ``git format-patch`` formatted patch series
   to openpower-firmware@lists.ozlabs.org, and cc joel@jms.id.au. Be
   sure to use ``--suppress-cc=sob`` when generating the patches so we
   don’t spam the community. The current tree is based on 5.1-stable
   (although we will always move to the latest stable kernel ASAP).

Bug fixes
---------

Whenever a stable release is tagged in
https://git.kernel.org/cgit/linux/kernel/git/stable/linux-stable.git/,
we will rebase our patches on top of that and create a new release.

If you are submitting patches upstream that you want to be included,
then ensure you cc stable as per the
`rules <https://git.kernel.org/cgit/linux/kernel/git/torvalds/linux.git/plain/Documentation/stable_kernel_rules.txt>`__.

Versioning
----------

Versions are the upstream version number, followed by ``-openpowerN``,
where N is the revision that counts up from 1 for the given upstream
version number. These versions will be present as tags in the git
repository hosted at https://github.com/open-power/linux.

We aim to follow "the latest upstream release".

For op-build stable trees, we follow the latest stable release of the
kernel that particular op-build release was made with. Since op-build
stable releases may outlast how long an upstream kernel is maintain for,
we will move up the kernel version we use until the next LTS kernel.
Once on an LTS kernel, an op-build stable release will stick with that
version.

Tree and patches
----------------

The kernel tree hosted at https://github.com/open-power/linux contains
the current release plus a set of patches that we carry. Ideally there
would be no patches carried, as everything should be upstream.

We take the commits in this tree between the upstream tag and the
openpower tag and generate a series of patches that are imported into
the op-build Buildroot overlay, and placed in
`op-build/openpower/linux <https://github.com/open-power/op-build/tree/master/openpower/linux>`_.
op-build then fetches the upstream tarball and applies these patches.
This way we don’t have to clone an entire tree when doing an op-build
build.

All patches are to head upstream *first*. There is a zero chance that
op-build will carry kernel patches for any time greater than "until the
next kernel release", and even then, only in *exceptional* circumstances.

Patches in the tree
-------------------

-  xhci: Reset controller on xhci shutdown
