#!/bin/bash

url="https://app.box.com/shared/static/r1wgmovy65vvo6cnwb8pz4lljt9osekl.bz2"
tarfile=AmberTools.tar.bz2
version='16'
EXCLUDED_TESTS=test.parmed
AMBERTOOLS_VERSION=18.0

function download_ambertools(){
	cd $HOME
    wget $url -O $tarfile
    tar -xf $tarfile
}

function install_cmake_travis(){
	sudo add-apt-repository -y "ppa:george-edison55/precise-backports" # get CMake 3
	sudo apt-get update
	
	# for SOME REASON, on Travis, emacs-common conflicts with cmake 3, and the following command will also cause emacs-common to get removed.  Why?  I have NO IDEA!
	sudo apt-get -y install --only-upgrade cmake cmake-data
}

function build_ambertools(){
    
	mkdir -p $HOME/TMP/build
    cd $HOME/TMP/build
	# we must run CMake twice because of the Fortran-compiler-version-not-being-autodetected bug in CMake 3.2
    cmake -DCMAKE_INSTALL_PREFIX=$HOME/TMP/install -DUNUSED_WARNINGS=FALSE -DUNINITIALIZED_WARNINGS=FALSE $CMAKE_OPTS $HOME/amber$version || echo "************************ this was supposed to fail ************************"
	cmake -DCMAKE_INSTALL_PREFIX=$HOME/TMP/install -DUNUSED_WARNINGS=FALSE -DUNINITIALIZED_WARNINGS=FALSE $CMAKE_OPTS $HOME/amber$version 

    make -j2
}

function install_ambertools_travis()
{
	# clang seems to break when GCC 5's headers are installed
	# in fact, you could say that it takes a header..... ba dum crash
	# anyway, we must only install the GCC 5 apt packages if we aren's using clang
	if [ "$COMPILER" = "gcc" ]; then
		CMAKE_OPTS="$CMAKE_OPTS -DCMAKE_C_COMPILER=gcc-5 -DCMAKE_CXX_COMPILER=g++-5 -DCMAKE_Fortran_COMPILER=gfortran-5"
		sudo apt-get -y install gcc-5 g++-5 gfortran-5
	elif [ "$COMPILER" = "clang" ]; then
		# must set CMAKE_Fortran_COMPILER_VERSION due to CMake bug #15372, whch was not fixed until CMake 3.3
		CMAKE_OPTS="$CMAKE_OPTS -DCOMPILER=clang -DCMAKE_Fortran_COMPILER_VERSION=4.6.4"
	fi
	
	if [ "$MPI" = "true" ]; then
		CMAKE_OPTS="$CMAKE_OPTS -DMPI=TRUE"
	fi
	
    set -ex

	build_ambertools
	make -j2 install
}

function install_ambertools_circleci(){
	CMAKE_OPTS="${CMAKE_OPTS} -DPRINT_PACKAGING_REPORT=TRUE -DPACKAGE_TYPE=DEB"

    build_ambertools
	
	echo "mpi.cfg:"
	cat $HOME/amber$version/AmberTools/src/mpi4py-2.0.0/mpi.cfg
	
	make -j2 install
	make -j2 package
}

function run_tests(){
    set -ex
    source $HOME/TMP/install/amber.sh
    ls $HOME/TMP/install
    ls $HOME/TMP/
    ls $HOME/TMP/*/
	
	cd $HOME/amber$version/AmberTools/test
	
	if [ "$MPI" = "true" ]; then
		./test_at_parallel.sh
	else
		./test_at_serial.sh
	fi
}
