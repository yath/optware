###########################################################
#
# perl-digest-sha1
#
###########################################################

PERL-DIGEST-SHA1_SITE=http://search.cpan.org/CPAN/authors/id/G/GA/GAAS
PERL-DIGEST-SHA1_VERSION=2.10
PERL-DIGEST-SHA1_SOURCE=Digest-SHA1-$(PERL-DIGEST-SHA1_VERSION).tar.gz
PERL-DIGEST-SHA1_DIR=Digest-SHA1-$(PERL-DIGEST-SHA1_VERSION)
PERL-DIGEST-SHA1_UNZIP=zcat

PERL-DIGEST-SHA1_IPK_VERSION=1

PERL-DIGEST-SHA1_CONFFILES=

PERL-DIGEST-SHA1_BUILD_DIR=$(BUILD_DIR)/perl-digest-sha1
PERL-DIGEST-SHA1_SOURCE_DIR=$(SOURCE_DIR)/perl-digest-sha1
PERL-DIGEST-SHA1_IPK_DIR=$(BUILD_DIR)/perl-digest-sha1-$(PERL-DIGEST-SHA1_VERSION)-ipk
PERL-DIGEST-SHA1_IPK=$(BUILD_DIR)/perl-digest-sha1_$(PERL-DIGEST-SHA1_VERSION)-$(PERL-DIGEST-SHA1_IPK_VERSION)_armeb.ipk

$(DL_DIR)/$(PERL-DIGEST-SHA1_SOURCE):
	$(WGET) -P $(DL_DIR) $(PERL-DIGEST-SHA1_SITE)/$(PERL-DIGEST-SHA1_SOURCE)

perl-digest-sha1-source: $(DL_DIR)/$(PERL-DIGEST-SHA1_SOURCE) $(PERL-DIGEST-SHA1_PATCHES)

$(PERL-DIGEST-SHA1_BUILD_DIR)/.configured: $(DL_DIR)/$(PERL-DIGEST-SHA1_SOURCE) $(PERL-DIGEST-SHA1_PATCHES)
	rm -rf $(BUILD_DIR)/$(PERL-DIGEST-SHA1_DIR) $(PERL-DIGEST-SHA1_BUILD_DIR)
	$(PERL-DIGEST-SHA1_UNZIP) $(DL_DIR)/$(PERL-DIGEST-SHA1_SOURCE) | tar -C $(BUILD_DIR) -xvf -
	mv $(BUILD_DIR)/$(PERL-DIGEST-SHA1_DIR) $(PERL-DIGEST-SHA1_BUILD_DIR)
	(cd $(PERL-DIGEST-SHA1_BUILD_DIR); \
		$(TARGET_CONFIGURE_OPTS) \
		CPPFLAGS="$(STAGING_CPPFLAGS)" \
		LDFLAGS="$(STAGING_LDFLAGS)" \
		perl Makefile.PL \
		PREFIX=/opt \
	)
	touch $(PERL-DIGEST-SHA1_BUILD_DIR)/.configured

perl-digest-sha1-unpack: $(PERL-DIGEST-SHA1_BUILD_DIR)/.configured

$(PERL-DIGEST-SHA1_BUILD_DIR)/.built: $(PERL-DIGEST-SHA1_BUILD_DIR)/.configured
	rm -f $(PERL-DIGEST-SHA1_BUILD_DIR)/.built
	$(MAKE) -C $(PERL-DIGEST-SHA1_BUILD_DIR)
	touch $(PERL-DIGEST-SHA1_BUILD_DIR)/.built

perl-digest-sha1: $(PERL-DIGEST-SHA1_BUILD_DIR)/.built

$(PERL-DIGEST-SHA1_BUILD_DIR)/.staged: $(PERL-DIGEST-SHA1_BUILD_DIR)/.built
	rm -f $(PERL-DIGEST-SHA1_BUILD_DIR)/.staged
	$(MAKE) -C $(PERL-DIGEST-SHA1_BUILD_DIR) DESTDIR=$(STAGING_DIR) install
	touch $(PERL-DIGEST-SHA1_BUILD_DIR)/.staged

perl-digest-sha1-stage: $(PERL-DIGEST-SHA1_BUILD_DIR)/.staged

$(PERL-DIGEST-SHA1_IPK): $(PERL-DIGEST-SHA1_BUILD_DIR)/.built
	rm -rf $(PERL-DIGEST-SHA1_IPK_DIR) $(BUILD_DIR)/perl-digest-sha1_*_armeb.ipk
	$(MAKE) -C $(PERL-DIGEST-SHA1_BUILD_DIR) DESTDIR=$(PERL-DIGEST-SHA1_IPK_DIR) install
	find $(PERL-DIGEST-SHA1_IPK_DIR)/opt -name '*.pod' -exec rm {} \;
	(cd $(PERL-DIGEST-SHA1_IPK_DIR)/opt/lib/perl5 ; \
		find . -name '*.so' -exec chmod +w {} \; ; \
		find . -name '*.so' -exec $(STRIP_COMMAND) {} \; ; \
		find . -name '*.so' -exec chmod -w {} \; ; \
	)
	install -d $(PERL-DIGEST-SHA1_IPK_DIR)/CONTROL
	install -m 644 $(PERL-DIGEST-SHA1_SOURCE_DIR)/control $(PERL-DIGEST-SHA1_IPK_DIR)/CONTROL/control
#	install -m 644 $(PERL-DIGEST-SHA1_SOURCE_DIR)/postinst $(PERL-DIGEST-SHA1_IPK_DIR)/CONTROL/postinst
#	install -m 644 $(PERL-DIGEST-SHA1_SOURCE_DIR)/prerm $(PERL-DIGEST-SHA1_IPK_DIR)/CONTROL/prerm
	echo $(PERL-DIGEST-SHA1_CONFFILES) | sed -e 's/ /\n/g' > $(PERL-DIGEST-SHA1_IPK_DIR)/CONTROL/conffiles
	cd $(BUILD_DIR); $(IPKG_BUILD) $(PERL-DIGEST-SHA1_IPK_DIR)

perl-digest-sha1-ipk: $(PERL-DIGEST-SHA1_IPK)

perl-digest-sha1-clean:
	-$(MAKE) -C $(PERL-DIGEST-SHA1_BUILD_DIR) clean

perl-digest-sha1-dirclean:
	rm -rf $(BUILD_DIR)/$(PERL-DIGEST-SHA1_DIR) $(PERL-DIGEST-SHA1_BUILD_DIR) $(PERL-DIGEST-SHA1_IPK_DIR) $(PERL-DIGEST-SHA1_IPK)
