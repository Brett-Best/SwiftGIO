#!/bin/sh
#
Module=Gio-2.0
MODULE=`echo "${Module}" | tr '[:lower:]' '[:upper:]'`
module=`echo "${Module}" | tr '[:upper:]' '[:lower:]'`
export PATH=/Library/Developer/Toolchains/swift-latest.xctoolchain/usr/bin:"${PATH}"
GOBJECT_LIBDIR=`pkg-config --libs-only-L gobject-introspection-1.0 2>/dev/null | tr ' ' '\n' | grep gobject-introspection | tail -n1 | cut -c3-`
GOBJECT_DIR=`dirname "${GOBJECT_LIBDIR}"`
for prefix in $PREFIX GOBJECT_DIR /usr/local /usr ; do
	gir_dir=${prefix}/share/gir-1.0
	gir=${gir_dir}/${Module}.gir
	if [ -e "${gir}" ] ; then
		export GIR=${gir}
		export GIR_DIR=${gir_dir}
	fi
done
if [ ! -e "${GIR}" ] ; then
	echo "*** ${GIR} does not exist!"
	echo "Make sure libgirepository1.0-dev is installed"
	echo "and can be found in /usr /usr/local or by pkg-config!"
	exit 1
fi
LINKFLAGS=`pkg-config --libs $module gio-unix-2.0 glib-2.0 | tr ' ' '\n' | sed 's/^/-Xlinker /' | tr '\n' ' '`
CCFLAGS=`pkg-config --cflags $module  gio-unix-2.0 glib-2.0 | tr ' ' '\n' | sed 's/^/-Xcc /' | tr '\n' ' ' `
gir2swift -p ${GIR_DIR}/GLib-2.0.gir -p ${GIR_DIR}/GObject-2.0.gir "${GIR}" | sed -f ${Module}.sed > Sources/${Module}.swift
echo  > Sources/SwiftGio.swift "import CGLib"
echo >> Sources/SwiftGio.swift "import GLib"
echo >> Sources/SwiftGio.swift "import GObject"
echo >> Sources/SwiftGio.swift ""
grep 'public protocol' Sources/${Module}.swift | cut -d' ' -f3 | cut -d: -f1 | sort -u | sed -e 's/^\(.*\)/public typealias _gio_\1 = \1/' >> Sources/SwiftGio.swift
echo >> Sources/SwiftGio.swift ""
grep 'public class' Sources/${Module}.swift | cut -d' ' -f3 | cut -d: -f1 | sort -u | sed -e 's/^\(.*\)/public typealias _gio_\1 = \1/' >> Sources/SwiftGio.swift
echo >> Sources/SwiftGio.swift ""
echo >> Sources/SwiftGio.swift "public struct Gio {"
grep 'public protocol' Sources/${Module}.swift | cut -d' ' -f3 | cut -d: -f1 | sort -u | sed -e 's/^\(.*\)/    public typealias \1 = _gio_\1/' >> Sources/SwiftGio.swift
echo >> Sources/SwiftGio.swift ""
grep 'public class' Sources/${Module}.swift | cut -d' ' -f3 | cut -d: -f1 | sort -u | sed -e 's/^\(.*\)/    public typealias \1 = _gio_\1/' >> Sources/SwiftGio.swift
echo >> Sources/SwiftGio.swift ""
grep 'public typealias' Sources/${Module}.swift | sed 's/^/    /' >> Sources/SwiftGio.swift
echo >> Sources/SwiftGio.swift "}"
exec swift build $CCFLAGS $LINKFLAGS "$@"
