#!/bin/bash
if [ $MSYSTEM != "MINGW32" ]; then
echo "You MUST launch MSYS2 using mingw32_shell.bat"
echo "OR set the PROCESS environment variable: MSYSTEM , to 'MINGW32', prior launching mintty.exe"
exit
fi
if [ ! -d ~/opencv ]; then
  git clone --recursive https://github.com/Itseez/opencv.git
else
  cd opencv
  git pull  
fi
cd ~
if [ ! -d ~/ocvcontrib ]; then
  git clone --recursive https://github.com/Itseez/opencv_contrib.git ocvcontrib
else
  cd ocvcontrib
  git pull
fi
cd ~
if [ ! -d ~/ocv32d ]; then
mkdir ~/ocv32d
fi
cd ~/ocv32d
if [ -f Makefile ]; then
make clean
fi

cd ~/opencv

cp ~/patches/mingw-w64-opencv/*.patch ./
patch -Np1 -i "mingw-w64-cmake.patch"
patch -Np1 -i "solve_deg3-underflow.patch"
#patch -Np1 -i "issue-4107.patch"
#4107 should have been fixed in master branch
patch -Np1 -i "remove-bindings-generation-DetectionBasedTracker.patch"
patch -Np1 -i "generate-proper-pkg-config-file.patch"
patch -Np1 -i "opencv-support-python-3.5.patch"
cd ~/ocv32d
THREAD=$(nproc)
THREAD=$((THREAD<2?1:THREAD-1))
PATH=${PATH}:${CUDA_PATH}
cmake \
    -G"MSYS Makefiles" \
    -DCMAKE_INSTALL_PREFIX="$(cygpath -wa /)mingw32" \
	-DCMAKE_C_FLAGS=" -m32 -DSTRSAFE_NO_DEPRECATE " \
	-DCMAKE_CXX_FLAGS=" -m32 -DSTRSAFE_NO_DEPRECATE " \
	-DCMAKE_EXE_LINKER_FLAGS=" -m32" \
    -DCMAKE_BUILD_TYPE=Debug \
	-DPKG_CONFIG_WITHOUT_PREFIX=ON \
	-DBUILD_SHARED_LIBS=ON \
	-DWITH_CUDA=OFF \
	-DWITH_VTK=OFF \
	-DWITH_GTK=OFF \
    -DWITH_OPENCL=ON \
    -DWITH_OPENGL=ON \
	-DCMAKE_SKIP_RPATH=ON \
    -DENABLE_PRECOMPILED_HEADERS=OFF \
 	-DCPACK_BINARY_7Z=ON \
	-DCPACK_BINARY_NSIS=OFF \
	-DOPENCV_EXTRA_MODULES_PATH=../ocvcontrib/modules \
	-DBUILD_opencv_text=OFF \
	-Wno-dev \
	~/opencv \

make -j$THREAD && make package
echo "build done."
if [ $# -gt 0 ] && [ "--enable-make-install" = "$1" ]; then
	if [ -e opencv.pc ]; then
		mv mv opencv.pc opencvt.pc
	fi
	make install
	cd $(cygpath -wa /)mingw32/lib/pkgconfig
	echo "rename..."
	sed -i -e '/Name:/s/OpenCV/OpenCVd/' ./opencv.pc
	mv opencv.pc opencvd.pc
	echo "done."
	if [ -e opencvt.pc ]; then
		mv opencvt.pc opencv.pc
	fi
fi
