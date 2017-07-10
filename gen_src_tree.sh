#!/bin/bash

SUBDIRS=${1:-10}
DEPTH=${2:-4}
OUT=${3:-$(pwd)/output/src}

rm -rf ${OUT}

function gendir {
	local curdir=$1
	local curdepth=$2
	local curlib=$(echo $curdir | tr / _ | tr - _)
	install -d $curdir
	sed s/FOO_FUNC/$curlib/ < foo.c > $curdir/foo.c
	if [ $curdepth -eq 1 ]; then
		sed s/FOO_FUNC/$curlib/ < main.c > $curdir/main.c
		echo "obj-y += main.o" >> $curdir/Makefile
		echo "set(CMAKE_NINJA_FORCE_RESPONSE_FILE 1)" >> $curdir/CMakeLists.txt
        echo '
set(SRC 
    main.c
    foo.c)
set(SRC_FLAGS
    ${CMAKE_CURRENT_SOURCE_DIR}/foo.c "-DCURDIR=${CMAKE_CURRENT_SOURCE_DIR}")' >> $curdir/CMakeLists.txt
		echo "TARGET := foo" > $curdir/boilermake.mk
		echo "SOURCES := main.c" >> $curdir/boilermake.mk
	fi
	echo "void $curlib();" > $curdir/foo.h
	echo "obj-y += foo.o" >> $curdir/Makefile
	echo "SOURCES += foo.c" >> $curdir/boilermake.mk
	if [ $curdepth -ne $DEPTH ]; then
		for i in `seq 1 ${SUBDIRS}`; do
			local tmp=$i
			gendir $curdir/$tmp $((curdepth + 1))
			sed "s/>/>\n#include \"$tmp\/foo.h\"\n/" -i $curdir/foo.c
			sed "s/^}/\t${curlib}_${tmp}\(\);\n}/" -i $curdir/foo.c
			echo "obj-y += $tmp/" >> $curdir/Makefile
			echo "ADD_SUBDIRECTORY($tmp)" >> $curdir/CMakeLists.txt
			echo "SUBMAKEFILES += $tmp/boilermake.mk" >> $curdir/boilermake.mk
		done
	fi
    if (( $curdepth > 1 )); then
        echo '
set(SRC 
    ${SRC}
    ${CMAKE_CURRENT_SOURCE_DIR}/foo.c 
    PARENT_SCOPE)
set(SRC_FLAGS
    ${SRC_FLAGS}
    ${CMAKE_CURRENT_SOURCE_DIR}/foo.c "-DCURDIR=${CMAKE_CURRENT_SOURCE_DIR}"
    PARENT_SCOPE)' >> $curdir/CMakeLists.txt
    fi
	echo "cflags-y = -D'CURDIR=$curdir'" >> $curdir/Makefile
	if [ $curdepth -eq 1 ]; then
        echo '
list(LENGTH SRC_FLAGS SRC_FLAGS_LENGTH)
math(EXPR i 0)

while(i LESS SRC_FLAGS_LENGTH)
    list(GET SRC_FLAGS ${i} file_path)
    math(EXPR i "${i}+1")
    list(GET SRC_FLAGS ${i} file_flag)
    set_source_files_properties(${file_path} PROPERTIES COMPILE_FLAGS ${file_flag})
    math(EXPR i "${i}+1")
endwhile()
ADD_EXECUTABLE(foo ${SRC})' >> $curdir/CMakeLists.txt
    fi
	echo "SRC_CFLAGS = -D'CURDIR=$curdir'" >> $curdir/boilermake.mk
}

echo "Generating sources under ${OUT}: tree depth ${DEPTH} subdirs ${SUBDIRS}"

gendir ${OUT} 1
