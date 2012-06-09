###########################################################
#
# collectd - statistics collection and monitoring daemon
#
#    http://collectd.org/
#
###########################################################

# COLLECTD_VERSION, COLLECTD_SITE and COLLECTD_SOURCE define
# the upstream location of the source code for the package.
# COLLECTD_DIR is the directory which is created when the source
# archive is unpacked.
# COLLECTD_UNZIP is the command used to unzip the source.
# It is usually "zcat" (for .gz) or "bzcat" (for .bz2)
#
# You should change all these variables to suit your package.
# Please make sure that you add a description, and that you
# list all your packages' dependencies, seperated by commas.
# 
# If you list yourself as MAINTAINER, please give a valid email
# address, and indicate your irc nick if it cannot be easily deduced
# from your name or email address.  If you leave MAINTAINER set to
# "NSLU2 Linux" other developers will feel free to edit.

COLLECTD_SITE=http://collectd.org/files
COLLECTD_VERSION=5.1.0
COLLECTD_SOURCE=collectd-$(COLLECTD_VERSION).tar.bz2
COLLECTD_DIR=collectd-$(COLLECTD_VERSION)
COLLECTD_UNZIP=bzcat
COLLECTD_MAINTAINER=Sebastian Schmidt <yath@yath.de>
COLLECTD_DESCRIPTION=statistics collection and monitoring daemon
COLLECTD_SECTION=utils
COLLECTD_PRIORITY=optional
COLLECTD_IPK_VERSION=1

COLLECTD_CONFFILES=/opt/etc/collectd.conf
COLLECTD_PATCHES=$(wildcard $(COLLECTD_SOURCE_DIR)/*.patch)
COLLECTD_CPPFLAGS=-Wno-deprecated-declarations
COLLECTD_LDFLAGS=

# conditional builds
# change this to yes once perl has been built with ithreads
COLLECTD_BUILD_PERL ?= no
COLLECTD_BUILD_PYTHON ?= yes
COLLECTD_BUILD_SENSORS ?= $(if $(filter lm-sensors,$(PACKAGES)), yes, no)

# --disable-foo for configure
#  (put plugins here that should not be built)
COLLECTD_CONFIGURE_DISABLE = \
amqp apple_sensors battery contextswitch \
curl_json dbi ethstat gmond ipmi ipvs java libvirt lpar \
madwifi mbmon memcachec modbus multimeter netapp netlink \
notify_desktop notify_email numa nut onewire oracle \
redis routeros tape ted tokyotyrant write_redis \
write_mongodb xmms zfs_arc \
rrdcached varnish

WHAT_TO_DO_WITH_IPK_DIR = :


# convenience macro to convert e.g. lm_sensors to collectd-plugin-lm-sensors
COLLECTD_PLUGIN_NAME = collectd-plugin-$(subst _,-,$(1))

# defines the rules for building a specific plugin .ipk
# eval the string returned.
define DEF_COLLECTD_PLUGIN
  COLLECTD_CONFIGURE_ENABLE += $(1)
  COLLECTD_BUILD_DEPS += $(2)

  COLLECTD_PLUGIN_$(1)_IPK_DIR=$(BUILD_DIR)/$(call COLLECTD_PLUGIN_NAME,$(1))-$(COLLECTD_VERSION)-ipk
  COLLECTD_PLUGIN_$(1)_IPK=$(BUILD_DIR)/$(call COLLECTD_PLUGIN_NAME,$(1))_$(COLLECTD_VERSION)-$(COLLECTD_IPK_VERSION)_$(TARGET_ARCH).ipk

  COLLECTD_PLUGINS_IPK_DIRS += $$(COLLECTD_PLUGIN_$(1)_IPK_DIR)
  COLLECTD_PLUGINS_IPKS += $$(COLLECTD_PLUGIN_$(1)_IPK)

  $$(COLLECTD_PLUGIN_$(1)_IPK_DIR)/CONTROL/control:
		@install -d $$(@D)
		@rm -f $$@
		@echo "Package: $(call COLLECTD_PLUGIN_NAME,$(1))" >>$$@
		@echo "Architecture: $$(TARGET_ARCH)" >>$$@
		@echo "Priority: $$(COLLECTD_PRIORITY)" >>$$@
		@echo "Section: $$(COLLECTD_SECTION)" >>$$@
		@echo "Version: $$(COLLECTD_VERSION)-$$(COLLECTD_IPK_VERSION)" >>$$@
		@echo "Maintainer: $$(COLLECTD_MAINTAINER)" >>$$@
		@echo "Source: $$(COLLECTD_SITE)/$$(COLLECTD_SOURCE)" >>$$@
		@echo "Description: $$(COLLECTD_DESCRIPTION) - $(3)" >>$$@
		@echo "Depends: collectd$(if $(2), $(2),)" >>$$@
		@echo "Suggests: " >>$$@
		@echo "Conflicts: " >>$$@

  $$(COLLECTD_PLUGIN_$(1)_IPK):
		install -d $$(COLLECTD_PLUGIN_$(1)_IPK_DIR)/$$(COLLECTD_LIBDIR)
		mv $$(COLLECTD_IPK_DIR)/$$(COLLECTD_LIBDIR)/$(1).* \
		   $$(COLLECTD_PLUGIN_$(1)_IPK_DIR)/$$(COLLECTD_LIBDIR)/
		if [ -e $$(COLLECTD_IPK_DIR)/$$(COLLECTD_MANDIR)/man5/collectd-$(1).5 ]; then \
		install -d $$(COLLECTD_PLUGIN_$(1)_IPK_DIR)/$$(COLLECTD_MANDIR)/man5/ && \
		mv $$(COLLECTD_IPK_DIR)/$$(COLLECTD_MANDIR)/man5/collectd-$(1).5 \
			$$(COLLECTD_PLUGIN_$(1)_IPK_DIR)/$$(COLLECTD_MANDIR)/man5/; fi
		$$(MAKE) $$(COLLECTD_PLUGIN_$(1)_IPK_DIR)/CONTROL/control
		cd $$(BUILD_DIR); $$(IPKG_BUILD) $$(COLLECTD_PLUGIN_$(1)_IPK_DIR)
		$$(WHAT_TO_DO_WITH_IPK_DIR) $$(COLLECTD_PLUGIN_$(1)_IPK_DIR)
endef

# defines the plugins to be built
#$(eval $(call DEF_COLLECTD_PLUGIN, plugin, dependencies, description))
$(eval $(call DEF_COLLECTD_PLUGIN,apache,libcurl,Apache httpd statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,apcups,,Statistics of UPSes by APC))
$(eval $(call DEF_COLLECTD_PLUGIN,ascent,,AscentEmu player statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,bind,libcurl libxml2,ISC Bind nameserver statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,conntrack,,nf_conntrack statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,cpufreq,,CPU frequency statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,cpu,,CPU usage statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,csv,,CSV output plugin))
$(eval $(call DEF_COLLECTD_PLUGIN,curl,,CURL generic web statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,curl_xml,,CURL generic xml statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,df,,Filesystem usage statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,disk,,Disk usage statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,dns,libpcap,DNS traffic analysis))
$(eval $(call DEF_COLLECTD_PLUGIN,email,,EMail statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,entropy,,Entropy statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,exec,,Execution of external programs))
$(eval $(call DEF_COLLECTD_PLUGIN,filecount,,Count files in directories))
$(eval $(call DEF_COLLECTD_PLUGIN,fscache,,fscache statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,hddtemp,,Query hddtempd))
$(eval $(call DEF_COLLECTD_PLUGIN,interface,,Interface traffic statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,iptables,iptables,IPTables rule counters))
$(eval $(call DEF_COLLECTD_PLUGIN,irq,,IRQ statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,load,,System load))
$(eval $(call DEF_COLLECTD_PLUGIN,logfile,,File logging plugin))
$(eval $(call DEF_COLLECTD_PLUGIN,match_empty_counter,,The empty counter match))
$(eval $(call DEF_COLLECTD_PLUGIN,match_hashed,,The hashed match))
$(eval $(call DEF_COLLECTD_PLUGIN,match_regex,,The regex match))
$(eval $(call DEF_COLLECTD_PLUGIN,match_timediff,,The timediff match))
$(eval $(call DEF_COLLECTD_PLUGIN,match_value,,The value match))
$(eval $(call DEF_COLLECTD_PLUGIN,md,,md (Linux software RAID) devices))
$(eval $(call DEF_COLLECTD_PLUGIN,memcached,,memcached statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,memory,,Memory usage))
$(eval $(call DEF_COLLECTD_PLUGIN,mysql,mysql5,MySQL statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,network,libgcrypt,Network communication plugin))
$(eval $(call DEF_COLLECTD_PLUGIN,nfs,,NFS statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,nginx,,nginx statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,ntpd,,ntpd statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,olsrd,,olsrd statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,openvpn,,OpenVPN client statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,powerdns,,PowerDNS statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,processes,,Process statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,protocols,,Protocol (IP, TCP, ...) statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,rrdtool,rrdtool,RRDTool output plugin))
$(eval $(call DEF_COLLECTD_PLUGIN,serial,,serial port traffic))
$(eval $(call DEF_COLLECTD_PLUGIN,snmp,net-snmp,SNMP querying plugin))
$(eval $(call DEF_COLLECTD_PLUGIN,swap,,Swap usage statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,syslog,,Syslog logging plugin))
$(eval $(call DEF_COLLECTD_PLUGIN,table,,Parsing of tabular data))
$(eval $(call DEF_COLLECTD_PLUGIN,tail,,Parsing of logfiles))
$(eval $(call DEF_COLLECTD_PLUGIN,target_notification,,The notification target))
$(eval $(call DEF_COLLECTD_PLUGIN,target_replace,,The replace target))
$(eval $(call DEF_COLLECTD_PLUGIN,target_scale,,The scale target))
$(eval $(call DEF_COLLECTD_PLUGIN,target_set,,The set target))
$(eval $(call DEF_COLLECTD_PLUGIN,target_v5upgrade,,The v5upgrade target))
$(eval $(call DEF_COLLECTD_PLUGIN,tcpconns,,TCP connection statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,teamspeak2,,TeamSpeak2 server statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,thermal,,Linux ACPI thermal zone statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,threshold,,Threshold checking plugin))
$(eval $(call DEF_COLLECTD_PLUGIN,unixsock,,Unixsock communication plugin))
$(eval $(call DEF_COLLECTD_PLUGIN,uptime,,Uptime statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,users,,User statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,uuid,,UUID as hostname plugin))
$(eval $(call DEF_COLLECTD_PLUGIN,vmem,,Virtual memory statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,vserver,,Linux VServer statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,wireless,,Wireless statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,write_graphite,,Graphite / Carbon output plugin))
$(eval $(call DEF_COLLECTD_PLUGIN,write_http,libcurl,HTTP output plugin))


#### conditional plugins ####

### build perl? ###
ifeq (yes,$(COLLECTD_BUILD_PERL))
$(eval $(call DEF_COLLECTD_PLUGIN,perl,perl,Perl interpreter))
# perl's ExtUtils::Embed is somewhat broken in optware.
# try to pass the right[tm] settings below.

# environment variables passed to configure
COLLECTD_PERL_CONFIGURE_ENV = \
	PERL_CFLAGS="-I$(STAGING_LIB_DIR)/$(PERL_LIB_CORE_DIR)" \
	PERL_LDFLAGS="-Wl,-rpath,/opt/lib/$(PERL_LIB_CORE_DIR) \
		-L$(STAGING_LIB_DIR)/$(PERL_LIB_CORE_DIR) \
		-L/opt/lib/perl5/$(PERL_VERSION)/$(PERL_ARCH)/CORE" \
	PERL_LIBS="-lperl -lm -lcrypt -lpthread"

# path to host perl installation
COLLECTD_PERL_CONFIGURE_OPTS = --with-libperl=$(PERL_HOSTPERL)

else
# no perl :(
COLLECTD_CONFIGURE_DISABLE += perl

endif
### end build perl? ###

### build python? ###
ifeq (yes,$(COLLECTD_BUILD_PYTHON))
$(eval $(call DEF_COLLECTD_PLUGIN,python,python27,Python interpreter))
COLLECTD_BUILD_DEPS += python27-host
# distutils.sysconfig returns libpython23.a instead of -lpython sometimes
# which causes the link to fail. correct that below.

# value for PYTHONPATH environment variable
COLLECTD_PYTHONPATH = $(STAGING_LIB_DIR)/python$(PYTHON27_VERSION_MAJOR)

# host python
COLLECTD_PYTHON = $(HOST_STAGING_PREFIX)/bin/python$(PYTHON27_VERSION_MAJOR)

# the libraries with libfoo.{a,so} replaced by -lfoo
COLLECTD_PYTHON_LIBS = $(shell PYTHONPATH="$(COLLECTD_PYTHONPATH)" $(COLLECTD_PYTHON) -c \
'import distutils.sysconfig;l=distutils.sysconfig.get_config_vars("BLDLIBRARY")[0];\
import re;l=re.sub(r"\blib(.*)\.(a|so)\b", r"-l\1", l);import sys;sys.stdout.write(l)')

# environment passed to configure
COLLECTD_PYTHON_CONFIGURE_ENV = PYTHONPATH="$(COLLECTD_PYTHONPATH)" PYTHON_LIBS="$(COLLECTD_PYTHON_LIBS)"

# arguments passed to configure
COLLECTD_PYTHON_CONFIGURE_OPTS = --with-python=$(COLLECTD_PYTHON)

else
# no python
COLLECTD_CONFIGURE_DISABLE += python

endif
### end build python? ###

### build lm_sensors? ###
ifeq (yes,$(COLLECTD_BUILD_SENSORS))
# this is untested!
$(eval $(call DEF_COLLECTD_PLUGIN,lm_sensors,lm-sensors,lm_sensors statistics))
else
COLLECTD_CONFIGURE_DISABLE += lm_sensors
endif
### end build lm_sensors? ###

COLLECTD_BUILD_DIR=$(BUILD_DIR)/collectd
COLLECTD_SOURCE_DIR=$(SOURCE_DIR)/collectd
COLLECTD_IPK_DIR=$(BUILD_DIR)/collectd-$(COLLECTD_VERSION)-ipk
COLLECTD_IPK=$(BUILD_DIR)/collectd_$(COLLECTD_VERSION)-$(COLLECTD_IPK_VERSION)_$(TARGET_ARCH).ipk
COLLECTD_LIBDIR=/opt/lib/collectd
COLLECTD_MANDIR=/opt/man

# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
$(DL_DIR)/$(COLLECTD_SOURCE):
	$(WGET) -P $(@D) $(COLLECTD_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
.PHONY: collectd-source
collectd-source: $(DL_DIR)/$(COLLECTD_SOURCE) $(COLLECTD_PATCHES)

# unpacks and patches the source
$(COLLECTD_BUILD_DIR)/.source: $(DL_DIR)/$(COLLECTD_SOURCE) $(COLLECTD_PATCHES)
	rm -rf $(BUILD_DIR)/$(COLLECTD_DIR) $(@D)
	$(COLLECTD_UNZIP) $(DL_DIR)/$(COLLECTD_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	if test -n "$(COLLECTD_PATCHES)" ; \
		then cat $(COLLECTD_PATCHES) | \
		patch -d $(BUILD_DIR)/$(COLLECTD_DIR) -p1 ; \
	fi
	if test "$(BUILD_DIR)/$(COLLECTD_DIR)" != "$(@D)" ; \
		then mv $(BUILD_DIR)/$(COLLECTD_DIR) $(@D) ; \
	fi
	autoreconf -vif $(@D)
	touch $@

# the libraries that might be staged, doesn't hurt if one is not found during
# configure.
# netsnmp must be specified directly to the net-snmp-config binary, the configure
# script is broken (tests for +x, which is, surprise, also true for a directory).
COLLECTD_STAGED_LIBS = libiptc libmemcached libmysql libvarnish libsensors python

# reduce/uniq helper function, from http://www.cmcrossroads.com/ask-mr-make/10025-gnu-make-user-defined-functions-part-1
.PHONY: COLLECTD_reduce COLLECTD_check_uniq COLLECTD_uniq
COLLECTD_reduce = $(if $(strip $2),$(call COLLECTD_reduce,$1,$(wordlist 2,$(words $2),$2),$(call $1,$(firstword $2),$3)),$3)
COLLECTD_check_uniq = $(if $(filter $1,$2),$2,$2 $1)
COLLECTD_uniq = $(call COLLECTD_reduce,COLLECTD_check_uniq,$1)

# builds the build dependencies and runs configure
$(COLLECTD_BUILD_DIR)/.configured: $(COLLECTD_BUILD_DIR)/.source make/collectd.mk
	builddeps="$(addsuffix -stage,$(call COLLECTD_uniq,$(COLLECTD_BUILD_DEPS)))"; \
	if [ ! -z "$$builddeps" ]; then \
		$(MAKE) $$builddeps; \
	fi
	(cd $(@D); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS) $(COLLECTD_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS) $(COLLECTD_LDFLAGS)" \
		$(COLLECTD_PERL_CONFIGURE_ENV) \
		$(COLLECTD_PYTHON_CONFIGURE_ENV) \
		./configure \
		--build=$(GNU_HOST_NAME) \
		--host=$(GNU_TARGET_NAME) \
		--target=$(GNU_TARGET_NAME) \
		--prefix=/opt \
		--mandir=$(COLLECTD_MANDIR) \
		--disable-nls \
		--enable-static=no \
		--with-nan-emulation \
		--with-fp-layout=nothing \
		$(foreach lib,$(COLLECTD_STAGED_LIBS),--with-$(lib)=$(STAGING_PREFIX)) \
		--with-libnetsnmp=$(STAGING_PREFIX)/bin/net-snmp-config \
		$(COLLECTD_PERL_CONFIGURE_OPTS) \
		$(COLLECTD_PYTHON_CONFIGURE_OPTS) \
		$(addprefix --disable-,$(COLLECTD_CONFIGURE_DISABLE)) \
		$(addprefix --enable-,$(COLLECTD_CONFIGURE_ENABLE)) \
	)
	$(PATCH_LIBTOOL) $(@D)/libtool
	touch $@

.PHONY: collectd-unpack
collectd-unpack: $(COLLECTD_BUILD_DIR)/.configured

# This builds the actual binary.
$(COLLECTD_BUILD_DIR)/.built: $(COLLECTD_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

# This is the build convenience target.
.PHONY: collectd
collectd: $(COLLECTD_BUILD_DIR)/.built

# staging target
$(COLLECTD_BUILD_DIR)/.staged: $(COLLECTD_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

.PHONY: collectd-stage
collectd-stage: $(COLLECTD_BUILD_DIR)/.staged

# This rule creates a control file for ipkg
$(COLLECTD_IPK_DIR)/CONTROL/control:
	@install -d $(@D)
	@rm -f $@
	@echo "Package: collectd" >>$@
	@echo "Architecture: $(TARGET_ARCH)" >>$@
	@echo "Priority: $(COLLECTD_PRIORITY)" >>$@
	@echo "Section: $(COLLECTD_SECTION)" >>$@
	@echo "Version: $(COLLECTD_VERSION)-$(COLLECTD_IPK_VERSION)" >>$@
	@echo "Maintainer: $(COLLECTD_MAINTAINER)" >>$@
	@echo "Source: $(COLLECTD_SITE)/$(COLLECTD_SOURCE)" >>$@
	@echo "Description: $(COLLECTD_DESCRIPTION)" >>$@
	@echo "Depends: $(COLLECTD_DEPENDS)" >>$@
	@echo "Suggests: $(COLLECTD_SUGGESTS)" >>$@
	@echo "Conflicts: $(COLLECTD_CONFLICTS)" >>$@


# installs collectd with all plugins into $(COLLECTD_IPK_DIR).
# the plugins will be removed from there by the $(COLLECTD_PLUGINS_IPKS) targets.
.PHONY: collectd-install
collectd-install: $(COLLECTD_BUILD_DIR)/.built
	rm -rf $(COLLECTD_IPK_DIR) $(COLLECTD_PLUGINS_IPK_DIRS) \
		$(BUILD_DIR)/collectd_*_$(TARGET_ARCH).ipk $(BUILD_DIR)/collectd-plugin-*_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(COLLECTD_BUILD_DIR) DESTDIR=$(COLLECTD_IPK_DIR) install-strip
	# even though --disable-static is passed - and config.log tells us it doesn't
	# build static libraries - they are built and installed. dunno what's wrong there,
	# just delete them here
	find $(COLLECTD_IPK_DIR) -name \*.a -o -name \*.la -exec rm -f '{}' \;
	# TODO: remove unnecessary files

# This builds the IPK file for collectd _without_ plugins.
# The plugins' targets move their files away from $(COLLECTD_IPK_DIR),
# if we reach the $(COLLECTD_IPK) target only the base package is left.
$(COLLECTD_IPK): collectd-install $(COLLECTD_PLUGINS_IPKS)
	$(MAKE) $(COLLECTD_IPK_DIR)/CONTROL/control
	echo $(COLLECTD_CONFFILES) | sed -e 's/ /\n/g' > $(COLLECTD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(COLLECTD_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(COLLECTD_IPK_DIR)

# This is called from the top level makefile to create the IPK file.
.PHONY: collectd-ipk
collectd-ipk: $(COLLECTD_IPK)

# This is called from the top level makefile to clean all of the built files.
.PHONY: collectd-clean
collectd-clean:
	rm -f $(COLLECTD_BUILD_DIR)/.built
	-$(MAKE) -C $(COLLECTD_BUILD_DIR) clean

# This is called from the top level makefile to clean all dynamically created
# directories.
.PHONY: collectd-dirclean
collectd-dirclean:
	rm -rf $(BUILD_DIR)/$(COLLECTD_DIR) $(COLLECTD_BUILD_DIR) $(COLLECTD_IPK_DIR) $(COLLECTD_IPK)
#
#
# Some sanity check for the package.
#
collectd-check: $(COLLECTD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
