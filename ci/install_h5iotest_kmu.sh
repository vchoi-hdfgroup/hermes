#!/bin/bash

set -x
set -e
set -o pipefail

mkdir -p "${HOME}/install"

mkdir build
pushd build

DEPENDENCY_PREFIX="${HOME}/${LOCAL}"
INSTALL_PREFIX="${HOME}/install"

export CXXFLAGS="${CXXFLAGS} -std=c++17 -Werror -Wall -Wextra"

cmake                                                      \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX}               \
    -DCMAKE_PREFIX_PATH=${DEPENDENCY_PREFIX}               \
    -DCMAKE_BUILD_RPATH=${DEPENDENCY_PREFIX}/lib           \
    -DCMAKE_INSTALL_RPATH=${DEPENDENCY_PREFIX}/lib         \
    -DCMAKE_BUILD_TYPE=${BUILD_TYPE}                       \
    -DCMAKE_CXX_COMPILER=`which mpicxx`                    \
    -DCMAKE_C_COMPILER=`which mpicc`                       \
    -DBUILD_SHARED_LIBS=ON                                 \
    -DHERMES_ENABLE_COVERAGE=ON                            \
    -DHERMES_INTERCEPT_IO=OFF                              \
    -DHERMES_BUILD_BENCHMARKS=ON                           \
    -DHERMES_COMMUNICATION_MPI=ON                          \
    -DHERMES_BUILD_BUFFER_POOL_VISUALIZER=ON               \
    -DORTOOLS_DIR=${DEPENDENCY_PREFIX}                     \
    -DHERMES_USE_ADDRESS_SANITIZER=ON                      \
    -DHERMES_USE_THREAD_SANITIZER=OFF                      \
    -DHERMES_RPC_THALLIUM=ON                               \
    -DHERMES_DEBUG_HEAP=OFF                                \
    -DHERMES_ENABLE_VFD=ON                                 \
    -DHERMES_ENABLE_WRAPPER=ON                             \
    -DBUILD_TESTING=ON                                     \
    ..

cmake --build . -- -j4
make install
popd
# git clone https://github.com/jya-kmu/hdf5-iotest.git
# git clone https://github.com/HDFGroup/hdf5-iotest.git
git clone https://github.com/hyoklee/hdf5-iotest.git
cd hdf5-iotest
git checkout hermes-vfd
pwd
echo $LD_LIBRARY_PATH
export LD_LIBRARY_PATH="${INSTALL_PREFIX}/lib":$LD_LIBRARY_PATH
echo $LD_LIBRARY_PATH
echo $CFLAGS
export CFLAGS="-lhdf5_hermes_vfd"
echo $CFLAGS
echo $LDFLAGS
export LDFLAGS="-L${INSTALL_PREFIX}/lib -lhdf5_hermes_vfd"
echo $LDFLAGS
export HDF5_DIR="${HOME}/local/share/cmake"
ls ${HOME}/local/bin
ls ${INSTALL_PREFIX}/lib
mkdir build
cd build
cmake -DCMAKE_INSTALL_PREFIX=${HOME}/local  ..
make
make install
ls ${HOME}/local/bin
export HERMES_CONF="${HOME}/work/hermes/hermes/benchmarks/HermesVFD/hermes.conf_4KB_128KB_example"
GLOG_minloglevel=2 ${HOME}/local/bin/hdf5_iotest ${HOME}/work/hermes/hermes/benchmarks/HermesVFD/hdf5_iotest.ini

