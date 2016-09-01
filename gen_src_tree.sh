#!/bin/bash

SUBDIRS=${1:-10}
DEPTH=${2:-2}
OUT=${3:-$(pwd)/src}

rm -rf ${OUT}

function gendir {
	local curdir=$1
	local curdepth=$2
	local curlib=$(echo $curdir | tr / _)
	install -d $curdir
	sed s/FOO_FUNC/$curlib/ < foo.c > $curdir/foo.c
	if [ $curdepth -eq 1 ]; then
		sed s/FOO_FUNC/$curlib/ < main.c > $curdir/main.c
		echo "obj-y += main.o" >> $curdir/Makefile
		echo "set(CMAKE_NINJA_FORCE_RESPONSE_FILE 1)" >> $curdir/CMakeLists.txt
		echo "ADD_EXECUTABLE(foo main.c)" >> $curdir/CMakeLists.txt
		echo "TARGET_LINK_LIBRARIES(foo $curlib)" >> $curdir/CMakeLists.txt
		echo "TARGET := foo" > $curdir/boilermake.mk
		echo "SOURCES := main.c" >> $curdir/boilermake.mk
	fi
	echo "void $curlib();" > $curdir/foo.h
	echo "obj-y += foo.o" >> $curdir/Makefile
	echo "ADD_LIBRARY($curlib STATIC foo.c)" >> $curdir/CMakeLists.txt
	echo "SOURCES += foo.c" >> $curdir/boilermake.mk
	if [ $curdepth -ne $DEPTH ]; then
		for i in `seq 1 ${SUBDIRS}`; do
			local tmp=$i
			gendir $curdir/$tmp $((curdepth + 1))
			sed "s/>/>\n#include \"$tmp\/foo.h\"\n/" -i $curdir/foo.c
			sed "s/^}/\t${curlib}_${tmp}\(\);\n}/" -i $curdir/foo.c
			echo "obj-y += $tmp/" >> $curdir/Makefile
			echo "ADD_SUBDIRECTORY($tmp)" >> $curdir/CMakeLists.txt
			echo "TARGET_LINK_LIBRARIES($curlib ${curlib}_$tmp)" >> $curdir/CMakeLists.txt
			echo "SUBMAKEFILES += $tmp/boilermake.mk" >> $curdir/boilermake.mk
		done
	fi
	echo "cflags-y = -D'CURDIR=$curdir'" >> $curdir/Makefile
	echo "set(CMAKE_C_FLAGS \"\${CMAKE_C_FLAGS} -D'CURDIR=$curdir'\")" >> $curdir/CMakeLists.txt
	echo "SRC_CFLAGS = -D'CURDIR=$curdir'" >> $curdir/boilermake.mk
}

gendir ${OUT} 1
