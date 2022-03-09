#!/bin/bash
sudo apt update
sudo apt upgrade -y
sudo apt-get install -y gfortran
sudo apt-get install -y autoconf
sudo apt-get install -y automake
sudo apt-get install -y libtool
sudo apt-get install -y libtool-bin
sudo apt-get install -y mpich
sudo apt-get install -y lcov
sudo apt-get install -y zlib1g-dev
sudo apt-get install -y libsdl2-dev
sudo apt-get install -y cmake
git clone https://github.com/spack/spack
git clone https://github.com/mochi-hpc/mochi-spack-packages
git clone https://github.com/hyoklee/hermes
. ./spack/share/spack/setup-env.sh
spack external find perl
spack external find cmake
spack external find mpich
spack install mpi
spack compiler find
spack repo add mochi-spack-packages
spack repo add hermes/ci/hermes
spack install ior+hermes+hdf5
spack load ior+hermes+hdf5
ior

