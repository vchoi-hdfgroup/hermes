#!/bin/bash
brew install autoconf
brew install automake
brew install berkeley-db
brew install boost
brew install catch2
brew install cmake
brew install diffutils
brew install json-c
brew install libiconv
brew install libsigsegv
brew install mpich
brew install pkgconf

spack external find autoconf
spack external find automake
spack external find berkeley-db
spack external find boost
spack external find catch2
spack external find cmake
spack external find diffutils
spack external find json-c
spack external find libiconv
spack external find libfabric
spack external find libsigsegv
spack external find m4
spack external find mpich
spack external find perl
spack external find zlib
spack external find pkgconf

spack compiler find 
spack install mpi%gcc
spack install gortools%gcc
spack install hermes%gcc



