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

To build an image for a Blackbird system:

```
git clone --recursive https://github.com/open-power/op-build.git
cd op-build
./op-build blackbird_defconfig && ./op-build
```

There are also default configurations for other platforms in
`openpower/configs/`. Current POWER9 platforms include Witherspoon,
Boston (p9dsu), Romulus, and Zaius.

Buildroot/op-build supports both native and cross-compilation - it will
automatically download and build an appropriate toolchain as part of the build
process, so you don't need to worry about setting up a
cross-compiler. Cross-compiling from a x86-64 host is officially supported.

The machine your building on will need Python 3, GCC 8.4 (or later), and
a handful of other packages (see below).

### Dependencies for *64-bit* Ubuntu/Debian systems

1. Install Ubuntu 26.04 or Debian 13 (x86_64 or ppc64le).
2. Enable Universe (Ubuntu only):

        sudo apt-get install software-properties-common
        sudo add-apt-repository universe
3. Install the packages necessary for the build:

        sudo apt-get install cscope universal-ctags libz-dev libexpat-dev \
          python3 python-is-python3 language-pack-en texinfo gawk cpio xxd \
          build-essential g++ git bison flex unzip \
          libssl-dev libxml-simple-perl libxml-sax-perl libxml-parser-perl libxml2-dev libxml2-utils xsltproc \
          wget bc rsync

### Dependencies for *64-bit* Fedora systems

1. Install Fedora 44 (x86_64 or ppc64le).
2. Install the packages necessary for the build:

        sudo dnf install gcc-c++ flex bison git ctags cscope expat-devel patch \
          zlib-devel zlib-static texinfo "perl(bigint)" "perl(XML::Simple)" \
          "perl(YAML)" "perl(XML::SAX)" "perl(Fatal)" "perl(Thread::Queue)" \
          "perl(Env)" "perl(XML::LibXML)" "perl(Digest::SHA1)" "perl(ExtUtils::MakeMaker)" \
          "perl(FindBin)" "perl(English)" "perl(Time::localtime)" "perl(open)" "perl(IPC::Cmd)" "perl(Time::Piece)" \
          libxml2-devel which wget unzip tar cpio python bzip2 bc findutils ncurses-devel \
          openssl-devel make libxslt vim-common lzo-devel python3 rsync hostname

### Building on a newer Fedora host with Toolbx

op-build officially targets Fedora 33. On a newer Fedora release, run the build
inside a Fedora 33 [Toolbx](https://containertoolbx.org/) container. Your home
directory is shared with the host, so you can keep the checkout where it is.

1. Create a Fedora 33 container (run on the host).

   On x86_64 the official image is used automatically:

        toolbox create --distro fedora --release 33 f33

   On ppc64le there is no official pre-built `fedora-toolbox:33` image, so build
   one locally first, tagging it with the name Toolbx expects, then create the
   container from it:

        git clone https://github.com/containers/toolbox.git
        cd toolbox/images/fedora/f33
        podman build -t localhost/fedora-toolbox:33 .
        toolbox create --image localhost/fedora-toolbox:33 f33

2. Enter the container and install the Fedora 33 build dependencies listed above
   (the same `sudo dnf install ...` command):

        toolbox enter f33

3. Still inside the container, build as usual:

        cd op-build
        ./op-build blackbird_defconfig && ./op-build

   Re-enter the container with `toolbox enter f33` for subsequent builds.

Alternatively, you do not have to enter the container at all. Because
`./op-build` sources the build environment itself, you can drive the build from
the host with `toolbox run` (useful for headless or scripted builds). From the
op-build checkout:

        toolbox run -c f33 ./op-build blackbird_defconfig
        toolbox run -c f33 ./op-build

The one-time dependency install can be run the same way:

        toolbox run -c f33 sudo dnf install <packages listed above>

