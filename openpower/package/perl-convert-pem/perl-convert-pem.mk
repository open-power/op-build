################################################################################
#
# perl-convert-pem
#
################################################################################

PERL_CONVERT_PEM_VERSION = 0.08
PERL_CONVERT_PEM_SOURCE = Convert-PEM-$(PERL_CONVERT_PEM_VERSION).tar.gz
PERL_CONVERT_PEM_SITE = $(BR2_CPAN_MIRROR)/authors/id/B/BT/BTROTT
HOST_PERL_CONVERT_PEM_DEPENDENCIES = host-perl-class-errorhandler host-perl-convert-asn1 host-perl-crypt-des-ede3
PERL_CONVERT_PEM_LICENSE = Artistic or GPLv1+
PERL_CONVERT_PEM_LICENSE_FILES = README

$(eval $(host-perl-package))
