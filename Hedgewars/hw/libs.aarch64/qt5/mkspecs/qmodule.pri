!host_build|!cross_compile {
    QMAKE_CFLAGS=-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 
    QMAKE_CXXFLAGS=-g -O2 -fstack-protector-strong -Wformat -Werror=format-security -Wdate-time -D_FORTIFY_SOURCE=2 
    QMAKE_LFLAGS=-Wl,-Bsymbolic-functions -Wl,-z,relro -Wl,--as-needed
}
QT_CPU_FEATURES.arm64 = cx16 neon
QT.global_private.enabled_features = alloca_h alloca dbus dbus-linked gui libudev network posix_fallocate reduce_exports release_tools sql system-zlib testlib widgets xml
QT.global_private.disabled_features = sse2 alloca_malloc_h android-style-assets avx2 private_tests gc_binaries reduce_relocations stack-protector-strong
PKG_CONFIG_EXECUTABLE = /usr/bin/aarch64-linux-gnu-pkg-config
QMAKE_LIBS_DBUS = /usr/lib/aarch64-linux-gnu/libdbus-1.so
QMAKE_INCDIR_DBUS = /usr/include/dbus-1.0 /usr/lib/aarch64-linux-gnu/dbus-1.0/include
QMAKE_LIBS_LIBUDEV = /lib/aarch64-linux-gnu/libudev.so
QT_COORD_TYPE = double
QMAKE_LIBS_ZLIB = /usr/lib/aarch64-linux-gnu/libz.so
CONFIG -= precompile_header
QT_BUILD_PARTS += libs examples tools
CONFIG += compile_examples enable_new_dtags largefile neon nostrip
QT_HOST_CFLAGS_DBUS += -I/usr/include/dbus-1.0 -I/usr/lib/aarch64-linux-gnu/dbus-1.0/include
