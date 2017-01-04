################################################################################
#
# perl-crypt-des-ede3
#
################################################################################

PERL_CRYPT_DES_EDE3_VERSION = 0.01
PERL_CRYPT_DES_EDE3_SOURCE = Crypt-DES_EDE3-$(PERL_CRYPT_DES_EDE3_VERSION).tar.gz
PERL_CRYPT_DES_EDE3_SITE = $(BR2_CPAN_MIRROR)/authors/id/B/BT/BTROTT
PERL_CRYPT_DES_EDE3_LICENSE_FILES = README

$(eval $(host-perl-package))
