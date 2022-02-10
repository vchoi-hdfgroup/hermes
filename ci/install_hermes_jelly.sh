#!/bin/bash

. /scr/hyoklee/src/spack/share/spack/setup-env.sh
spack load mpich@3.4.2
spack load mochi-thallium
spack load gortools 
spack load catch2 
spack load sdl2
spack load hdf5@develop-1.13
set -x
set -e
set -o pipefail


rm -rf build
mkdir build
pushd build

INSTALL_PREFIX="${HOME}/${LOCAL}"

export CXXFLAGS="${CXXFLAGS} -std=c++17 -Wno-error -Wall -Wextra"
cmake                                                      \
    -DCMAKE_INSTALL_PREFIX=${INSTALL_PREFIX}               \
    -DCMAKE_PREFIX_PATH=${INSTALL_PREFIX}                  \
    -DCMAKE_BUILD_RPATH=${INSTALL_PREFIX}/lib              \
    -DCMAKE_INSTALL_RPATH=${INSTALL_PREFIX}/lib            \
    -DCMAKE_BUILD_TYPE=${BUILD_TYPE}                       \
    -DCMAKE_CXX_COMPILER=`which mpicxx`                    \
    -DCMAKE_C_COMPILER=`which mpicc`                       \
    -DHERMES_ENABLE_DOXYGEN=ON                             \
    -DBUILD_SHARED_LIBS=ON                                 \
    -DHERMES_ENABLE_COVERAGE=ON                            \
    -DHERMES_INTERCEPT_IO=OFF                              \
    -DHERMES_BUILD_BENCHMARKS=ON                           \
    -DHERMES_COMMUNICATION_MPI=ON                          \
    -DHERMES_BUILD_BUFFER_POOL_VISUALIZER=ON               \
    -DORTOOLS_DIR=${INSTALL_PREFIX}                        \
    -DHERMES_USE_ADDRESS_SANITIZER=ON                      \
    -DHERMES_USE_THREAD_SANITIZER=OFF                      \
    -DHERMES_RPC_THALLIUM=ON                               \
    -DHERMES_DEBUG_HEAP=OFF                                \
    -DHERMES_ENABLE_VFD=ON                                 \
    -DBUILD_TESTING=ON                                     \
    ..

cmake --build . -- -j4
ctest -VV

popd
