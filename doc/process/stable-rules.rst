.. _stable-rules:

=======================================
op-build stable tree rules and releases
=======================================

Our stable tree process follows processes similar to other open source projects
such as the Linux Kernel and Buildroot, as do several OpenPOWER Firmware
components such as Skiboot and Petitboot.

The purpose of a -stable tree is to give vendors a stable base to create
firmware releases from and to incorporate into service packs. New stable
releases contain critical fixes only.

As a general rule, only the most recent op-build release gets a maintained
-stable tree. If you wish to maintain an older tree, speak up! For example,
with my IBMer hat on, we'll maintain branches that we ship in products.

What patches are accepted?
--------------------------

* Patches must be obviously correct and tested

  * A Tested-by signoff is *important*
* A patch must fix a real bug
* No trivial patches, such fixups belong in main branch
* Not fix a purely theoretical problem unless you can prove how
  it's exploitable
* The patch, or an equivalent one, must already be in master

  * Submitting to both at the same time is okay, but back-porting is better

HOWTO submit to stable
----------------------

1. Make a pull request with "[stable op-build-N.N.y]" in subject (where N.N.y
   is the stable branch to which you are targeting)

   * This targets the patch *ONLY* to the stable branch.

     * Such commits will *NOT* be merged into master.
   * Use this when:

     a. cherry-picking a fix from master
     b. fixing something that is only broken in stable
     c. fix in stable needs to be completely different than in master

     If b or c: explain why.
   * If cherry-picking, include the following at the top of your
     commit message (or use the -x option to git-cherry-pick): ::

       commit <sha1> upstream.
   * If the patch has been modified, explain why in description.

2. Add a comment on the PR indicating that a PR should also go to a stable
   branch when making a Pull request to master

   * This targets the patch to master and stable.
   * You can target a patch to a specific stable tree by putting that in the
     comment
   * You can ask for prerequisites to be cherry-picked.

Trees
-----

* https://github.com/open-power/op-build/ (or via ssh at ``git@github.com:open-power/op-build.git`` )

  * (branches are op-build-X.Y.y - e.g. op-build-2.0.y)

* Some stable versions may last longer than others

  * So there may be op-build-2.0.y and op-build-2.4.y actively maintained
    and op-build-2.0.y could possibly outlast op-build-2.4.y.
