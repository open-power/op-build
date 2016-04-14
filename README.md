# OpenPower Firmware Build Environment

The OpenPower firmware build process uses Buildroot to create a toolchain and
build the various components of the PNOR firmware, including Hostboot, Skiboot,
OCC, Petitboot etc.

## Development

Issues, Milestones, pull requests and code hosting is on github:
https://github.com/open-power/op-build

Mailing list: openpower-firmware@lists.ozlabs.org  
Info/Subscribe: https://lists.ozlabs.org/listinfo/openpower-firmware  
Archives: https://lists.ozlabs.org/pipermail/openpower-firmware/  

## Building an image

```
git clone --recursive git@github.com:open-power/op-build.git
cd op-build
. op-build-env
op-build palmetto_defconfig && op-build
```

This will build an image for a Palmetto system. There exists default
configurations for other platforms in openpower/configs/ such as
Habanero and Firestone.

### Dependancies for *64-bit* Ubuntu/Debian systems

1. Install Ubuntu (>= 14.04) or Debian (>= 7.5) 64-bit.
2. Enable Universe:

        sudo apt-get install software-properties-common
        sudo add-apt-repository universe
3. Install the packages necessary for the build:

        sudo apt-get install cscope ctags libz-dev libexpat-dev \
          python language-pack-en texinfo \
          build-essential g++ git bison flex unzip \
          libxml-simple-perl libxml-sax-perl libxml2-dev libxml2-utils xsltproc \
          wget bc

### Dependancies for *64-bit* Fedora systems

1. Install Fedora 23 64-bit.
2. Install the packages necessary for the build:

        sudo dnf install gcc-c++ flex bison git ctags cscope expat-devel patch \
          zlib-devel zlib-static texinfo perl-bignum "perl(XML::Simple)" \
          "perl(YAML)" "perl(XML::SAX)" "perl(Fatal)" "perl(Thread::Queue)" \
          "perl(Env)" "perl(XML::LibXML)" "perl(Digest::SHA1)" libxml2-devel \
          which wget unzip tar cpio python bzip2 bc findutils ncurses-devel

