MUSL_PREFIX := $(CURDIR)/temp/musl
CACHE_DIR := $(HOME)/.cache/cursed-menus
CACHE_BUILD := $(CACHE_DIR)/build
CACHE_MUSL := $(CACHE_DIR)/musl
NCURSES_TAR := $(CACHE_BUILD)/ncurses-6.5.tar.gz
NCURSES_DIR := $(CACHE_BUILD)/ncurses-6.5


.PHONY: ncurses clean clean-cache


ncurses: $(MUSL_PREFIX)/lib/libncursesw.a

$(MUSL_PREFIX)/lib/libncursesw.a: $(CACHE_MUSL)/lib/libncursesw.a
	mkdir -p $(MUSL_PREFIX)
	cp -a $(CACHE_MUSL)/. $(MUSL_PREFIX)/

$(CACHE_MUSL)/lib/libncursesw.a: $(NCURSES_TAR)
	mkdir -p $(CACHE_BUILD) $(CACHE_MUSL)
	test -d $(NCURSES_DIR) || tar -C $(CACHE_BUILD) -xf $(NCURSES_TAR)
	cd $(NCURSES_DIR) && \
	CC="zig cc -target x86_64-linux-musl" \
	./configure \
	--prefix=$(CACHE_MUSL) \
	--with-shared=no \
	--enable-widec \
	--with-normal \
	--with-termlib \
	--without-debug \
	--enable-pc-files \
	--with-pkg-config-libdir=$(CACHE_MUSL)/lib/pkgconfig
	$(MAKE) -C $(NCURSES_DIR) -j$(nproc)
	$(MAKE) -C $(NCURSES_DIR) install

$(NCURSES_TAR):
	mkdir -p $(CACHE_BUILD)
	curl -L -o $(NCURSES_TAR) https://ftp.gnu.org/gnu/ncurses/ncurses-6.5.tar.gz

clean:
	rm -rf temp

clean-cache:
	rm -rf $(CACHE_DIR)
