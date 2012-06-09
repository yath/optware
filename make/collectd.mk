###########################################################
#
# collectd
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
COLLECTD_DEPENDS=
COLLECTD_SUGGESTS=
COLLECTD_CONFLICTS=

COLLECTD_BUILD_PERL ?= yes
COLLECTD_BUILD_PYTHON ?= yes

COLLECTD_CONFIGURE_DISABLE= \
amqp apple_sensors battery contextswitch \
curl_json dbi gmond ipmi ipvs java libvirt lpar \
madwifi mbmon memcachec modbus multimeter netapp netlink \
notify_desktop notify_email numa nut onewire oracle \
redis routeros tape ted tokyotyrant write_redis \
write_mongodb xmms zfs_arc \
lm_sensors \
rrdcached varnish

WHAT_TO_DO_WITH_IPK_DIR = :

COLLECTD_LIBDIR=/opt/lib/collectd
COLLECTD_MANDIR=/opt/man

COLLECTD_PLUGIN_NAME = collectd-plugin-$(subst _,-,$(1))
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
$(eval $(call DEF_COLLECTD_PLUGIN,ethstat,,Stats from NIC driver))
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
#$(eval $(call DEF_COLLECTD_PLUGIN,varnish,varnish,Varnish cache statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,vmem,,Virtual memory statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,vserver,,Linux VServer statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,wireless,,Wireless statistics))
$(eval $(call DEF_COLLECTD_PLUGIN,write_graphite,,Graphite / Carbon output plugin))
$(eval $(call DEF_COLLECTD_PLUGIN,write_http,libcurl,HTTP output plugin))

ifeq (yes,$(COLLECTD_BUILD_PERL))
$(eval $(call DEF_COLLECTD_PLUGIN,perl,perl,Perl interpreter))
COLLECTD_PERL_CONFIGURE_ENV = \
	PERL_CFLAGS="-I$(STAGING_LIB_DIR)/$(PERL_LIB_CORE_DIR)" \
	PERL_LDFLAGS="-Wl,-rpath,/opt/lib/$(PERL_LIB_CORE_DIR) \
		-L$(STAGING_LIB_DIR)/$(PERL_LIB_CORE_DIR) \
		-L/opt/lib/perl5/$(PERL_VERSION)/$(PERL_ARCH)/CORE" \
	PERL_LIBS="-lperl -lm -lcrypt -lpthread"
COLLECTD_PERL_CONFIGURE_OPTS = --with-libperl=$(PERL_HOSTPERL)
else
COLLECTD_CONFIGURE_DISABLE += perl
endif

ifeq (yes,$(COLLECTD_BUILD_PYTHON))
$(eval $(call DEF_COLLECTD_PLUGIN,python,python27,Python interpreter))
# COLLECTD_BUILD_DEPS += python3-host
COLLECTD_PYTHONPATH = $(STAGING_LIB_DIR)/python$(PYTHON27_VERSION_MAJOR)
COLLECTD_PYTHON = $(HOST_STAGING_PREFIX)/bin/python$(PYTHON27_VERSION_MAJOR)
COLLECTD_PYTHON_LIBS = $(shell PYTHONPATH="$(COLLECTD_PYTHONPATH)" $(COLLECTD_PYTHON) -c \
'import distutils.sysconfig;l=distutils.sysconfig.get_config_vars("BLDLIBRARY")[0];\
import re;l=re.sub(r"\blib(.*)\.(a|so)\b", r"-l\1", l);import sys;sys.stdout.write(l)')
COLLECTD_PYTHON_CONFIGURE_ENV = PYTHONPATH="$(COLLECTD_PYTHONPATH)" PYTHON_LIBS="$(COLLECTD_PYTHON_LIBS)"
COLLECTD_PYTHON_CONFIGURE_OPTS = --with-python=$(COLLECTD_PYTHON)
else
COLLECTD_CONFIGURE_DISABLE += python
endif

#
# COLLECTD_IPK_VERSION should be incremented when the ipk changes.
#
COLLECTD_IPK_VERSION=1

#
# COLLECTD_CONFFILES should be a list of user-editable files
#COLLECTD_CONFFILES=/opt/etc/collectd.conf /opt/etc/init.d/SXXcollectd

#
# COLLECTD_PATCHES should list any patches, in the the order in
# which they should be applied to the source code.
#
COLLECTD_PATCHES=$(wildcard $(COLLECTD_SOURCE_DIR)/*.patch)

#
# If the compilation of the package requires additional
# compilation or linking flags, then list them here.
#
COLLECTD_CPPFLAGS=-Wno-deprecated-declarations
COLLECTD_LDFLAGS=

#
# COLLECTD_BUILD_DIR is the directory in which the build is done.
# COLLECTD_SOURCE_DIR is the directory which holds all the
# patches and ipkg control files.
# COLLECTD_IPK_DIR is the directory in which the ipk is built.
# COLLECTD_IPK is the name of the resulting ipk files.
#
# You should not change any of these variables.
#
COLLECTD_BUILD_DIR=$(BUILD_DIR)/collectd
COLLECTD_SOURCE_DIR=$(SOURCE_DIR)/collectd
COLLECTD_IPK_DIR=$(BUILD_DIR)/collectd-$(COLLECTD_VERSION)-ipk
COLLECTD_IPK=$(BUILD_DIR)/collectd_$(COLLECTD_VERSION)-$(COLLECTD_IPK_VERSION)_$(TARGET_ARCH).ipk

.PHONY: collectd-source collectd-unpack collectd collectd-stage collectd-ipk collectd-clean collectd-dirclean collectd-check

#
# This is the dependency on the source code.  If the source is missing,
# then it will be fetched from the site using wget.
#
$(DL_DIR)/$(COLLECTD_SOURCE):
	$(WGET) -P $(@D) $(COLLECTD_SITE)/$(@F) || \
	$(WGET) -P $(@D) $(SOURCES_NLO_SITE)/$(@F)

#
# The source code depends on it existing within the download directory.
# This target will be called by the top level Makefile to download the
# source code's archive (.tar.gz, .bz2, etc.)
#
collectd-source: $(DL_DIR)/$(COLLECTD_SOURCE) $(COLLECTD_PATCHES)

# reduce/uniq helper function, from http://www.cmcrossroads.com/ask-mr-make/10025-gnu-make-user-defined-functions-part-1
COLLECTD_reduce = $(if $(strip $2),$(call COLLECTD_reduce,$1,$(wordlist 2,$(words $2),$2),$(call $1,$(firstword $2),$3)),$3)
COLLECTD_check_uniq = $(if $(filter $1,$2),$2,$2 $1)
COLLECTD_uniq = $(call COLLECTD_reduce,COLLECTD_check_uniq,$1)

#
# This target unpacks the source code in the build directory.
# If the source archive is not .tar.gz or .tar.bz2, then you will need
# to change the commands here.  Patches to the source code are also
# applied in this target as required.
#
# This target also configures the build within the build directory.
# Flags such as LDFLAGS and CPPFLAGS should be passed into configure
# and NOT $(MAKE) below.  Passing it to configure causes configure to
# correctly BUILD the Makefile with the right paths, where passing it
# to Make causes it to override the default search paths of the compiler.
#
# If the compilation of the package requires other packages to be staged
# first, then do that first (e.g. "$(MAKE) <bar>-stage <baz>-stage").
#
# If the package uses  GNU libtool, you should invoke $(PATCH_LIBTOOL) as
# shown below to make various patches to it.
#
# XXX add make/collectd.mk back

# doesn't hurt if one is not found during configure.
# netsnmp must be specified directly to the net-snmp-config binary, the configure
# script is broken (tests for +x, which is, surprise, also true for a directory).
COLLECTD_STAGED_LIBS = libiptc libmemcached libmysql libvarnish libsensors python

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

collectd-unpack: $(COLLECTD_BUILD_DIR)/.configured

#
# This builds the actual binary.
#
$(COLLECTD_BUILD_DIR)/.built: $(COLLECTD_BUILD_DIR)/.configured
	rm -f $@
	$(MAKE) -C $(@D)
	touch $@

#
# This is the build convenience target.
#
collectd: $(COLLECTD_BUILD_DIR)/.built

#
# If you are building a library, then you need to stage it too.
#
$(COLLECTD_BUILD_DIR)/.staged: $(COLLECTD_BUILD_DIR)/.built
	rm -f $@
	$(MAKE) -C $(@D) DESTDIR=$(STAGING_DIR) install
	touch $@

collectd-stage: $(COLLECTD_BUILD_DIR)/.staged

#
# This rule creates a control file for ipkg.  It is no longer
# necessary to create a seperate control file under sources/collectd
#
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

#
# This builds the IPK file.
#
# Binaries should be installed into $(COLLECTD_IPK_DIR)/opt/sbin or $(COLLECTD_IPK_DIR)/opt/bin
# (use the location in a well-known Linux distro as a guide for choosing sbin or bin).
# Libraries and include files should be installed into $(COLLECTD_IPK_DIR)/opt/{lib,include}
# Configuration files should be installed in $(COLLECTD_IPK_DIR)/opt/etc/collectd/...
# Documentation files should be installed in $(COLLECTD_IPK_DIR)/opt/doc/collectd/...
# Daemon startup scripts should be installed in $(COLLECTD_IPK_DIR)/opt/etc/init.d/S??collectd
#
# You may need to patch your application to make it use these locations.

.PHONY: collectd-install
collectd-install: $(COLLECTD_BUILD_DIR)/.built
	rm -rf $(COLLECTD_IPK_DIR) $(COLLECTD_PLUGINS_IPK_DIRS) \
		$(BUILD_DIR)/collectd_*_$(TARGET_ARCH).ipk $(BUILD_DIR)/collectd-plugin-*_*_$(TARGET_ARCH).ipk
	$(MAKE) -C $(COLLECTD_BUILD_DIR) DESTDIR=$(COLLECTD_IPK_DIR) install-strip
	# even though --disable-static is passed - and config.log tells us it doesn't
	# build static libraries - they are built and installed. dunno what's wrong there,
	# just delete them here
	find $(COLLECTD_IPK_DIR) -name \*.a -o -name \*.la -exec rm -f '{}' \;
	# TODO: remove unnecessary manpages

$(COLLECTD_IPK): collectd-install $(COLLECTD_PLUGINS_IPKS)
	$(MAKE) $(COLLECTD_IPK_DIR)/CONTROL/control
	echo $(COLLECTD_CONFFILES) | sed -e 's/ /\n/g' > $(COLLECTD_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(COLLECTD_IPK_DIR)
	$(WHAT_TO_DO_WITH_IPK_DIR) $(COLLECTD_IPK_DIR)

#
# This is called from the top level makefile to create the IPK file.
#
collectd-ipk: $(COLLECTD_IPK)

#
# This is called from the top level makefile to clean all of the built files.
#
collectd-clean:
	rm -f $(COLLECTD_BUILD_DIR)/.built
	-$(MAKE) -C $(COLLECTD_BUILD_DIR) clean

#
# This is called from the top level makefile to clean all dynamically created
# directories.
#
collectd-dirclean:
	rm -rf $(BUILD_DIR)/$(COLLECTD_DIR) $(COLLECTD_BUILD_DIR) $(COLLECTD_IPK_DIR) $(COLLECTD_IPK)
#
#
# Some sanity check for the package.
#
collectd-check: $(COLLECTD_IPK)
	perl scripts/optware-check-package.pl --target=$(OPTWARE_TARGET) $^
