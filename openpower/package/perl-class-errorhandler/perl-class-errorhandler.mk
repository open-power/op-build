################################################################################
#
# perl-class-errorhandler
#
################################################################################

PERL_CLASS_ERRORHANDLER_VERSION = 0.04
PERL_CLASS_ERRORHANDLER_SOURCE = Class-ErrorHandler-$(PERL_CLASS_ERRORHANDLER_VERSION).tar.gz
PERL_CLASS_ERRORHANDLER_SITE = $(BR2_CPAN_MIRROR)/authors/id/T/TO/TOKUHIROM
PERL_CLASS_ERRORHANDLER_LICENSE = Artistic or GPLv1+
PERL_CLASS_ERRORHANDLER_LICENSE_FILES = LICENSE

$(eval $(host-perl-package))
