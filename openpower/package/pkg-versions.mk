################################################################################
#
# pkg-versions
#
# Read VERSION.readme in the current directory to learn about the version
# string structure
#
################################################################################

define OPENPOWER_SUBPACKAGE_VERSION

$(2)_VERSION_FILE = $$(OPENPOWER_VERSION_DIR)/$(1).version.txt
$(2)_FW_VERSION_SHORT_FILE = $$(OPENPOWER_VERSION_DIR)/$(1).fwversion_short.txt
$(2)_FW_VERSION_LONG_FILE = $$(OPENPOWER_VERSION_DIR)/$(1).fwversion_long.txt
ALL_SUBPACKAGE_VERSIONS += $$($(2)_VERSION_FILE)

### Create subpackage patch file
define $(2)_OPENPOWER_PATCH_FILE

mkdir -p "$$(OPENPOWER_VERSION_DIR)";

# Remove patch file to start off fresh
if [ -f $$(OPENPOWER_VERSION_DIR)/$(1).patch.txt ]; then \
		rm -rf $$(OPENPOWER_VERSION_DIR)/$(1).patch.txt; \
fi

# Check all global patch directories
$$(foreach path, $$(BR2_GLOBAL_PATCH_DIR),if ls $$(path)/$(1)/*.patch 2>/dev/null; then \
		sha512sum $$(path)/$(1)/*.patch | sha512sum | \
		xargs echo >> $$(OPENPOWER_VERSION_DIR)/$(1).tmp_patch.txt; fi;)

# Check the package patch dir, $$(PKGDIR) doesn't exist when running the version rules
if [ -n "$$(PKGDIR)" ]; then \
	if ls $$(PKGDIR)*.patch 2>/dev/null; then sha512sum $$(PKGDIR)*.patch | sha512sum | \
		xargs echo >> $$(OPENPOWER_VERSION_DIR)/$(1).tmp_patch.txt; \
	fi; \
else \
	if ls $$(BR2_EXTERNAL_OP_BUILD_PATH)/package/$(1)/*.patch 2>/dev/null; then sha512sum \
		$$(BR2_EXTERNAL_OP_BUILD_PATH)/package/$(1)/*.patch | sha512sum | \
		xargs echo >> $$(OPENPOWER_VERSION_DIR)/$(1).tmp_patch.txt; \
	fi; \
fi

# If this is for linux, also check openpower/linux
if [ "LINUX" == "$(2)" ]; then \
	if ls $$(BR2_EXTERNAL_OP_BUILD_PATH)/$(1)/*.patch 2>/dev/null; then sha512sum \
		$$(BR2_EXTERNAL_OP_BUILD_PATH)/$(1)/*.patch | sha512sum | \
		xargs echo >> $$(OPENPOWER_VERSION_DIR)/$(1).tmp_patch.txt; \
	fi; \
fi;

# Combine all the patches found in the package and global package directories
if [ -f $$(OPENPOWER_VERSION_DIR)/$(1).tmp_patch.txt ]; then \
		cat $$(OPENPOWER_VERSION_DIR)/$(1).tmp_patch.txt | sha512sum | cut -c 1-7 | \
		xargs echo -n > $$(OPENPOWER_VERSION_DIR)/$(1).patch.txt; \
fi

# Remove the tmp_patch file
if [ -f $$(OPENPOWER_VERSION_DIR)/$(1).tmp_patch.txt ]; then \
	rm -rf $$(OPENPOWER_VERSION_DIR)/$(1).tmp_patch.txt; \
fi

endef # $(2)_OPENPOWER_PATCH_FILE

### Create subpackage version file
define $(2)_OPENPOWER_VERSION_FILE

mkdir -p "$$(OPENPOWER_VERSION_DIR)"

# Add package name
echo -n "	$(1)-" > $$($(2)_VERSION_FILE)

# If site local
# Add site local and user, local commit, if local is dirty
# Else not local
# Add package version, extraversion if linux, op-build is dirty, op-build patches
if [ "$$($(2)_SITE_METHOD)" == "local" ]; then \
echo -n "site_local-" >> $$($(2)_VERSION_FILE); \
whoami | xargs echo -n >> $$($(2)_VERSION_FILE); \
echo -n "-" >> $$($(2)_VERSION_FILE); \
\
cd "$$($(2)_SITE)"; (git describe --always --dirty || echo "unknown") \
	|sed -e 's/$(1)-//' | xargs echo -n\
	>> $$($(2)_VERSION_FILE); \
\
else \
\
[ `echo -n $$($(2)_VERSION) | wc -c` == "40" ] && (echo -n $$($(2)_VERSION) | \
	sed "s/^\([0-9a-f]\{7\}\).*/\1/;s/$(1)-//;" >> $$($(2)_VERSION_FILE)) \
	|| echo -n $$($(2)_VERSION) | sed -e 's/$(1)-//' >> $$($(2)_VERSION_FILE); \
\
if [ "LINUX" == "$(2)" ]; then \
	if ls $$(BUILD_DIR)/$(1)-$$($(2)_VERSION)/Makefile 1>/dev/null; then \
		head $$(BUILD_DIR)/$(1)-$$($(2)_VERSION)/Makefile | grep EXTRAVERSION \
		| cut -d ' ' -f 3 | \
		xargs echo -n >> $$($(2)_VERSION_FILE); \
	fi; \
fi; \
\
if [ -f $$(OPENPOWER_VERSION_DIR)/$(1).patch.txt ]; then \
	echo -n "-p" >> $$($(2)_VERSION_FILE); \
	cat $$(OPENPOWER_VERSION_DIR)/$(1).patch.txt >> $$($(2)_VERSION_FILE); fi \
fi

# Check the package name against HOSTBOOT_P to filter out other
# packages such as HOSTBOOT_BINARIES, we only want HOSTBOOT_P10, HOSTBOOT_P11, etc.
# This allows future usage of this logic since the Hostboot repo build process
# seeds from this output file and does -NOT- know about package names, etc.
# All Hostboot repo build needs is the git hashes built which are cat'd to the
# _FW_VERSION_*_FILE
#
# If OPBUILD_VERSION is used in the environment then we trim
# the string since we are limited to 16 chars for the PELs in Hostboot.
# If OPBUILD_VERSION is empty we run the git commands to get the hashes.
# Sample OPBUILD_VERSION  OP10-v2.7-10.146 gets trimmed to v2.7-10.146
# sed 's/[^\-]*-//' up until first dash
#
# The *_FW_VERSION_SHORT_FILE is the FW subsystem identifier to aide
# mapping op-build images to proper build level.  The FW subsystem
# string is subsequently embedded in the Hostboot images built.
#
$(if $(findstring HOSTBOOT_P, $(2)),
if [ -n "$$(OPBUILD_VERSION)" ]; then \
	echo -n "$$(OPBUILD_VERSION)" \
	| sed 's/[^\-]*-//' | xargs echo -n\
	> $$($(2)_FW_VERSION_SHORT_FILE); \
else \
cd "$$(BR2_EXTERNAL_OP_BUILD_PATH)"; (git describe --always || echo "unknown") \
	| sed -e 's/\(.*\)-.*/\1/' | xargs echo -n\
	> $$($(2)_FW_VERSION_SHORT_FILE); \
fi\)

# Remove with sed any empty line
# /./ matches any character, including newline
# ! negates the select, makes the command apply to lines which do -NOT- match selector, i.e. empty lines
# d deletes the selected lines
# sed `/./!d'
$(if $(findstring HOSTBOOT_P, $(2)),
cd "$$(BR2_EXTERNAL_OP_BUILD_PATH)"; (git describe --always --long || echo "unknown") \
	| sed '/./!d' | xargs echo -n\
	> $$($(2)_FW_VERSION_LONG_FILE); \)

# Add new line to version.txt
echo "" >> $$($(2)_VERSION_FILE);
echo "" >> $$($(2)_FW_VERSION_SHORT_FILE);
echo "" >> $$($(2)_FW_VERSION_LONG_FILE);

endef # $(2)_OPENPOWER_VERSION_FILE

# Add appropriate templates to hooks if they're not there already
ifeq (,$$(findstring $(2)_OPENPOWER_PATCH_FILE,$$($(2)_POST_PATCH_HOOKS)))
$(2)_POST_PATCH_HOOKS += $(2)_OPENPOWER_PATCH_FILE
endif
ifeq (,$$(findstring $(2)_OPENPOWER_VERSION_FILE,$$($(2)_PRE_CONFIGURE_HOOKS)))
$(2)_PRE_CONFIGURE_HOOKS += $(2)_OPENPOWER_VERSION_FILE
endif

# Top-level rule to print or generate a subpackage version
$(1)-version: $$(if $$(wildcard $$($(2)_VERSION_FILE)),$(1)-print-version,$(1)-build-version)

# Rule to print out subpackage version
$(1)-print-version:
		@echo "=== $(2)_VERSION ==="
		@cat $$($(2)_VERSION_FILE) | xargs echo

# Rule to generate subpackage version
$(1)-build-version:
		@echo "=== $(2)_VERSION ==="
		@echo "	Searching for patches..."
		@$$($(2)_OPENPOWER_PATCH_FILE)
		@echo "	End of patches...";
		@echo "	Creating version string (various output may display)..."
		@$$($(2)_OPENPOWER_VERSION_FILE)
		@echo "	End creating version string..."
		@echo -n "	version: "; cat $$($(2)_VERSION_FILE) | xargs echo

endef # OPENPOWER_SUBPACKAGE_VERSION


####
# $(1) is the lowercase package version
# $(2) is the uppercase package version
####
define INNER_OPENPOWER_VERSION

$(2)_VERSION_FILE = $$(OPENPOWER_VERSION_DIR)/$(1).version.txt
ifeq ($$(BR2_PACKAGE_OPENPOWER_PNOR_P10),y)
UPPER_CASE_SIGN_MODE = $(call UPPERCASE,$$(BR2_OPENPOWER_P10_SECUREBOOT_SIGN_MODE))
CONFIG_NAME = $$(BR2_OPENPOWER_P10_CONFIG_NAME)
VERSIONED_SUBPACKAGES = $$(OPENPOWER_PNOR_P10_VERSIONED_SUBPACKAGES)
else
UPPER_CASE_SIGN_MODE = $(call UPPERCASE,$$(BR2_OPENPOWER_SECUREBOOT_SIGN_MODE))
CONFIG_NAME = $$(BR2_OPENPOWER_CONFIG_NAME)
VERSIONED_SUBPACKAGES = $$(OPENPOWER_VERSIONED_SUBPACKAGES)
endif

$$(eval $$(foreach pkg,$$(VERSIONED_SUBPACKAGES), \
		$$(call OPENPOWER_SUBPACKAGE_VERSION,$$(pkg),$$(call UPPERCASE,$$(pkg)))))

### Combine subpackage files into one version file
define $(2)_OPENPOWER_VERSION_FILE

mkdir -p "$$(OPENPOWER_VERSION_DIR)"

# Add vendor or default open-power

if [ -n "$$(OPBUILD_VENDOR)" ]; then \
echo -n "$$(OPBUILD_VENDOR)-" > $$($(2)_VERSION_FILE); \
else \
echo -n "open-power-" > $$($(2)_VERSION_FILE); \
fi

# Add platform or default from defconfig
if [ -n "$$(OPBUILD_PLATFORM)" ]; then \
echo -n "$$(OPBUILD_PLATFORM)-" >> $$($(2)_VERSION_FILE); \
else \
echo -n "$$(CONFIG_NAME)-" >> $$($(2)_VERSION_FILE); \
fi

# Add op-build version
# Order: OPBUILD_VERSION, tag, commit, unknown
if [ -n "$$(OPBUILD_VERSION)" ]; then \
	echo -n "$$(OPBUILD_VERSION)" >> $$($(2)_VERSION_FILE); \
else \
cd "$$(BR2_EXTERNAL_OP_BUILD_PATH)"; (git describe --always --dirty || echo "unknown") \
	| xargs echo -n \
	>> $$($(2)_VERSION_FILE); \
fi

# Flag whether op-build is production signed
if [ "$$(UPPER_CASE_SIGN_MODE)" == 'PRODUCTION' ]; then \
	echo -n "-prod" >> $$($(2)_VERSION_FILE); \
fi

# Add new line to $$($(2)_VERSION_FILE)
echo "" >> $$($(2)_VERSION_FILE);

# Add a specific line for op-build if it has been overwritten
if [ -n "$$(OPBUILD_VENDOR)" ]; then \
echo -n "	op-build-" >> $$($(2)_VERSION_FILE); \
(cd "$$(BR2_EXTERNAL_OP_BUILD_PATH)"; (git describe --always --dirty  || echo "unknown")) \
	| xargs echo \
	>> $$($(2)_VERSION_FILE); \
fi

# Include the currently checked-out buildroot version
echo -n "	buildroot-" >> $$($(2)_VERSION_FILE);
(git describe --always --dirty || echo "unknown") \
	| xargs echo \
	>> $$($(2)_VERSION_FILE); \

# Include the named pnor build name if there is one
if [ -n "$$(OPBUILD_BUILDNAME)" ]; then \
     echo -n "	op-build-buildname-" >> $$($(2)_VERSION_FILE); \
     echo $$(OPBUILD_BUILDNAME) >> $$($(2)_VERSION_FILE); \
fi

# Combing subpackage version files into $$($(2)_VERSION_FILE)
$$(foreach verFile,$$(ALL_SUBPACKAGE_VERSIONS),
	if [ -f $$(verFile) ]; then cat $$(verFile) \
	>>$$($(2)_VERSION_FILE); fi )

endef #  $(2)_OPENPOWER_VERSION_FILE

$(2)_PRE_BUILD_HOOKS += $(2)_OPENPOWER_VERSION_FILE

# Top-level rule to print or generate openpower-pnor version
$(1)-version: $$(if $$(wildcard $$($(2)_VERSION_FILE)),$(1)-print-version,$(1)-build-version)

# Rule to print out pnor version
$(1)-print-version:
		@echo "=== $(2)_VERSION ==="
		@cat $$($(2)_VERSION_FILE)
		@echo ""; echo "**See openpower/package/VERSION.readme for detailed info on package strings"; echo ""

# Rule to generate pnor version
$(1)-build-version: $$(foreach pkg,$$(VERSIONED_SUBPACKAGES), $$(pkg)-version)
		@$$($(2)_OPENPOWER_VERSION_FILE)
		@echo "=== $(2)_VERSION ==="
		@cat $$($(2)_VERSION_FILE)
		@echo ""; echo "**See openpower/package/VERSION.readme for detailed info on package strings"; echo ""

# Rule to force re-generation of all versioned subpackages
$(1)-build-version-all: $$(foreach pkg,$$(VERSIONED_SUBPACKAGES), $$(pkg)-build-version)
		@$$($(2)_OPENPOWER_VERSION_FILE)
		@echo "=== $(2)_VERSION ==="
		@cat $$($(2)_VERSION_FILE)
		@echo ""; echo "**See openpower/package/VERSION.readme for detailed info on package strings"; echo ""

endef # INNER_OPENPOWER_VERSION

OPENPOWER_VERSION = $(call INNER_OPENPOWER_VERSION,$(pkgname),$(call UPPERCASE,$(pkgname)))

