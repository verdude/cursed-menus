ncurses:
        curl -LO https://ftp.gnu.org/gnu/ncurses/ncurses-6.5.tar.gz
        tar xf ncurses-6.5.tar.gz
        cd ncurses-6.5 && \
                CC="zig cc -target x86_64-linux-musl" \
                ./configure \
                        --prefix=/opt/musl           \
                        --with-shared=no             \
                        --enable-widec               \
                        --with-normal                \
                        --with-termlib               \
                        --without-debug              \
                        --enable-pc-files            \
                        --with-pkg-config-libdir=/opt/musl/lib/pkgconfig

        make -C ncurses-6.5 -j$(nproc)
        make -C ncurses-6.5 install
