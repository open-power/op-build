# OpenPOWER Firmware Build Environment

The OpenPOWER firmware build process uses Buildroot to create a toolchain and
build the various components of the PNOR firmware, including Hostboot, Skiboot,
OCC, Petitboot etc.

## Documentation

https://open-power.github.io/op-build/

See the doc/ directory for documentation source. Contributions
are *VERY* welcome!

## Development

Issues, Milestones, pull requests and code hosting is on GitHub:
https://github.com/open-power/op-build

See [CONTRIBUTING.md](CONTRIBUTING.md) for howto contribute code.

* Mailing list: openpower-firmware@lists.ozlabs.org
* Info/Subscribe: https://lists.ozlabs.org/listinfo/openpower-firmware  
* Archives: https://lists.ozlabs.org/pipermail/openpower-firmware/

## Building an image

To build an image for a Palmetto system:

```
git clone --recursive git@github.com:open-power/op-build.git
cd op-build
. op-build-env
op-build palmetto_defconfig && op-build
```

There are also default configurations for other platforms in
`openpower/configs/`. Current POWER8 platforms include Habanero,
Firestone, and Garrison. Current POWER9 platforms include Witherspoon,
Boston (p9dsu), Romulus, and Zaius.

Buildroot/op-build supports both native and cross-compilation - it will
automatically download and build an appropriate toolchain as part of the build
process, so you don't need to worry about setting up a
cross-compiler. Cross-compiling from a x86-64 host is officially supported.

### Dependencies for *64-bit* Ubuntu/Debian systems

1. Install Ubuntu (>= 14.04) or Debian (>= 7.5) 64-bit.
2. Enable Universe (Ubuntu only):

        sudo apt-get install software-properties-common
        sudo add-apt-repository universe
3. Install the packages necessary for the build:

        sudo apt-get install cscope ctags libz-dev libexpat-dev \
          python language-pack-en texinfo \
          build-essential g++ git bison flex unzip \
          libssl-dev libxml-simple-perl libxml-sax-perl libxml2-dev libxml2-utils xsltproc \
          wget bc

### Dependencies for *64-bit* Fedora systems

1. Install Fedora 25 64-bit (older Fedora should also work).
2. Install the packages necessary for the build:

        sudo dnf install gcc-c++ flex bison git ctags cscope expat-devel patch \
          zlib-devel zlib-static texinfo perl-bignum "perl(XML::Simple)" \
          "perl(YAML)" "perl(XML::SAX)" "perl(Fatal)" "perl(Thread::Queue)" \
          "perl(Env)" "perl(XML::LibXML)" "perl(Digest::SHA1)" libxml2-devel \
          which wget unzip tar cpio python bzip2 bc findutils ncurses-devel

