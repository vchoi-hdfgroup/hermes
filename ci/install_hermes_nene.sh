#!/bin/bash
brew install mpich
brew install cmake
spack compiler find
spack external find cmake
spack external find mpich
spack load mpich
spack install mpi



