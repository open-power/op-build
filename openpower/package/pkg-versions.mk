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
	if ls $$(BR2_EXTERNAL)/package/$(1)/*.patch 2>/dev/null; then sha512sum \
		$$(BR2_EXTERNAL)/package/$(1)/*.patch | sha512sum | \
		xargs echo >> $$(OPENPOWER_VERSION_DIR)/$(1).tmp_patch.txt; \
	fi; \
fi

# If this is for linux, also check openpower/linux
if [ $(filter "LINUX", "$(2)") == "$(2)" ]; then \
	if ls $$(BR2_EXTERNAL)/$(1)/*.patch 2>/dev/null; then sha512sum \
		$$(BR2_EXTERNAL)/$(1)/*.patch | sha512sum | \
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

endef ###

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
cd "$$($(2)_SITE)"; (git describe --tags || git log -n1 --pretty=format:'%h' || echo "unknown") \
	| sed 's/\(.*\)-g\([0-9a-f]\{7\}\).*/\2/;s/$(1)-//;' | xargs echo -n \
	>> $$($(2)_VERSION_FILE); \
\
cd "$$($(2)_SITE)"; git describe --all --dirty | grep -e "-dirty" | sed 's/.*\(-dirty\)/\1/;' | \
	xargs echo -n >> $$($(2)_VERSION_FILE); \
else \
\
[ `echo -n $$($(2)_VERSION) | wc -c` == "40" ] && (echo -n $$($(2)_VERSION) | \
	sed "s/^\([0-9a-f]\{7\}\).*/\1/;s/$(1)-//;" >> $$($(2)_VERSION_FILE)) \
	|| echo -n $$($(2)_VERSION) | sed -e 's/$(1)-//' >> $$($(2)_VERSION_FILE); \
\
if [ $(filter "LINUX", "$(2)") == "$(2)" ]; then \
	if ls $$(BUILD_DIR)/$(1)-$$($(2)_VERSION)/Makefile 1>/dev/null; then \
		head $$(BUILD_DIR)/$(1)-$$($(2)_VERSION)/Makefile | grep EXTRAVERSION \
		| cut -d ' ' -f 3 | \
		xargs echo -n >> $$($(2)_VERSION_FILE); \
	fi; \
fi; \
\
cd "$$(BR2_EXTERNAL)"; git describe --all --dirty | \
	if grep -e "-dirty"; then \
	echo -n "-opdirty" >> $$($(2)_VERSION_FILE); \
	fi; \
\
if [ -f $$(OPENPOWER_VERSION_DIR)/$(1).patch.txt ]; then \
	echo -n "-" >> $$($(2)_VERSION_FILE); \
	cat $$(OPENPOWER_VERSION_DIR)/$(1).patch.txt >> $$($(2)_VERSION_FILE); fi \
fi

# Add new line to version.txt
echo "" >> $$($(2)_VERSION_FILE);

endef ###

# Add appropriate templates to hooks
$(2)_POST_PATCH_HOOKS += $(2)_OPENPOWER_PATCH_FILE
$(2)_PRE_BUILD_HOOKS += $(2)_OPENPOWER_VERSION_FILE

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

endef

define OPENPOWER_VERSION

UPPER_CASE_PKG = $(call UPPERCASE,$(1))
$$(UPPER_CASE_PKG)_VERSION_FILE = $$(OPENPOWER_VERSION_DIR)/$(1).version.txt


$$(eval $$(foreach pkg,$$(OPENPOWER_VERSIONED_SUBPACKAGES), \
		$$(call OPENPOWER_SUBPACKAGE_VERSION,$$(pkg),$$(call UPPERCASE,$$(pkg)))))

### Combine subpackage files into one version file
define $$(UPPER_CASE_PKG)_OPENPOWER_VERSION_FILE

mkdir -p "$$(OPENPOWER_VERSION_DIR)"

# Add vendor or default open-power
if [ "$$(OPBUILD_VENDOR)" != '' ]; then \
echo -n "$$(OPBUILD_VENDOR)-" > $$($$(UPPER_CASE_PKG)_VERSION_FILE); \
else \
echo -n "open-power-" > $$($$(UPPER_CASE_PKG)_VERSION_FILE); \
fi

# Add platform or default from defconfig
if [ "$$(OPBUILD_PLATFORM)" != '' ]; then \
echo -n "$$(OPBUILD_PLATFORM)-" >> $$($$(UPPER_CASE_PKG)_VERSION_FILE); \
else \
echo -n "$$(BR2_OPENPOWER_CONFIG_NAME)-" >> $$($$(UPPER_CASE_PKG)_VERSION_FILE); \
fi

# Add op-build version
# Order: OPBUILD_VERSION, tag, commit, unknown
if [ "$$(OPBUILD_VERSION)" != '' ]; then \
	echo -n "$$(OPBUILD_VERSION)" >> $$($$(UPPER_CASE_PKG)_VERSION_FILE); \
else \
cd "$$(BR2_EXTERNAL)"; (git describe --tags || git log -n1 --pretty=format:'%h' || echo "unknown") \
	| sed 's/\(.*\)-g\([0-9a-f]\{7\}\).*/\2/' | xargs echo -n \
	>> $$($$(UPPER_CASE_PKG)_VERSION_FILE); \
fi

# Check if op-build is dirty
cd "$$(BR2_EXTERNAL)"; git describe --all --dirty | grep -e "-dirty" | sed 's/.*\(-dirty\)/\1/' | \
	xargs echo -n >> $$($$(UPPER_CASE_PKG)_VERSION_FILE);

# Add new line to $$($$(UPPER_CASE_PKG)_VERSION_FILE)
echo "" >> $$($$(UPPER_CASE_PKG)_VERSION_FILE);

# Add a specific line for op-build if it has been overwritten
if [ "$$(OPBUILD_VENDOR)" != '' ]; then \
echo -n "	op-build-" >> $$($$(UPPER_CASE_PKG)_VERSION_FILE); \
cd "$$(BR2_EXTERNAL)"; (git describe --tags || git log -n1 --pretty=format:'%h' || echo "unknown") \
	| sed 's/\(.*\)-g\([0-9a-f]\{7\}\).*/\2/' | xargs echo -n \
	>> $$($$(UPPER_CASE_PKG)_VERSION_FILE); \
cd "$$(BR2_EXTERNAL)"; git describe --all --dirty | grep -e "-dirty" | sed 's/.*\(-dirty\)/\1/' | \
	xargs echo >> $$($$(UPPER_CASE_PKG)_VERSION_FILE); \
fi

# Include the currently checked-out buildroot version
echo -n "	buildroot-" >> $$($$(UPPER_CASE_PKG)_VERSION_FILE);
cd "./buildroot"; (git describe --tags || git log -n1 --pretty=format:'%h' || echo "unknown") \
	| sed 's/\(.*\)-g\([0-9a-f]\{7\}\).*/\2/' | xargs echo -n \
	>> $$($$(UPPER_CASE_PKG)_VERSION_FILE); \
git describe --all --dirty | grep -e "-dirty" | sed 's/.*\(-dirty\)/\1/' | \
	xargs echo >> $$($$(UPPER_CASE_PKG)_VERSION_FILE);


# Combing subpackage version files into $$($$(UPPER_CASE_PKG)_VERSION_FILE)
$$(foreach verFile,$$(ALL_SUBPACKAGE_VERSIONS),
	if [ -f $$(verFile) ]; then cat $$(verFile) \
	>> $$($$(UPPER_CASE_PKG)_VERSION_FILE); fi )

endef ###

$$(UPPER_CASE_PKG)_PRE_BUILD_HOOKS += $$(UPPER_CASE_PKG)_OPENPOWER_VERSION_FILE

# Top-level rule to print or generate openpower-pnor version
$(1)-version: $$(if $$(wildcard $$($$(UPPER_CASE_PKG)_VERSION_FILE)),$(1)-print-version,$(1)-build-version)

# Rule to print out pnor version
$(1)-print-version:
		@echo "=== $$(UPPER_CASE_PKG)_VERSION ==="
		@cat $$($$(UPPER_CASE_PKG)_VERSION_FILE)
		@echo ""; echo "**See openpower/package/VERSION.readme for detailed info on package strings"; echo ""

# Rule to generate pnor version
$(1)-build-version: $$(foreach pkg,$$(OPENPOWER_VERSIONED_SUBPACKAGES), $$(pkg)-version)
		@$$($$(UPPER_CASE_PKG)_OPENPOWER_VERSION_FILE)
		@echo "=== $$(UPPER_CASE_PKG)_VERSION ==="
		@cat $$($$(UPPER_CASE_PKG)_VERSION_FILE)
		@echo ""; echo "**See openpower/package/VERSION.readme for detailed info on package strings"; echo ""

# Rule to force re-generation of all versioned subpackages
$(1)-build-version-all: $$(foreach pkg,$$(OPENPOWER_VERSIONED_SUBPACKAGES), $$(pkg)-build-version)
		@$$($$(UPPER_CASE_PKG)_OPENPOWER_VERSION_FILE)
		@echo "=== $$(UPPER_CASE_PKG)_VERSION ==="
		@cat $$($$(UPPER_CASE_PKG)_VERSION_FILE)
		@echo ""; echo "**See openpower/package/VERSION.readme for detailed info on package strings"; echo ""

endef
