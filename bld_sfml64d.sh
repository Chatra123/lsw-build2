#!/bin/bash
if [ $MSYSTEM != "MINGW64" ]; then
echo "You MUST launch MSYS2 using mingw64_shell.bat"
echo "OR set the PROCESS environment variable: MSYSTEM , to 'MINGW64', prior launching mintty.exe"
exit
fi
if [ ! -d ~/sfml ]; then
  git clone --recursive https://github.com/SFML/SFML.git sfml
else
  cd sfml
  git pull  
fi
cd ~
if [ ! -d ~/sfml64d ]; then
mkdir ~/sfml64d
fi
cd ~/sfml64d
if [ -f Makefile ]; then
make clean
fi
cd ~/sfml64d
THREAD=$(nproc)
THREAD=$((THREAD<2?1:THREAD-1))
cmake \
    -G"MSYS Makefiles" \
    -DCMAKE_BUILD_TYPE=Debug \
	-DCMAKE_INSTALL_PREFIX=${MINGW_PREFIX} \
    -DSFML_BUILD_EXAMPLES=ON \
    -DSFML_BUILD_DOC=OFF \
    -DSFML_INSTALL_PKGCONFIG_FILES=OFF \
	-DSFML_USE_STATIC_STD_LIBS=ON \
	-DBUILD_SHARED_LIBS=OFF \
	${HOME}/sfml \

make -j$THREAD