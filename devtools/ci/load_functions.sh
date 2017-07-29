#!/bin/bash

url="https://app.box.com/shared/static/epq4p9l3cz79hkzcvj08kovi7z9r2ok6.bz2"
tarfile=AmberTools.tar.bz2
version='16'
EXCLUDED_TESTS=test.parmed
AMBERTOOLS_VERSION=18.0

function download_ambertools(){
	cd $HOME
    wget $url -O $tarfile
    tar -xf $tarfile
}

function build_ambertools(){
    
	mkdir -p $HOME/TMP/build
    cd $HOME/TMP/build
	# we must run CMake twice because of the Fortran-compiler-version-not-being-autodetected bug in CMake 3.2
    cmake -DCMAKE_INSTALL_PREFIX=$HOME/TMP/install -DUNUSED_WARNINGS=FALSE -DUNINITIALIZED_WARNINGS=FALSE $CMAKE_OPTS $HOME/amber$version || echo "************************\nthis was supposed to fail\n************************"
	cmake -DCMAKE_INSTALL_PREFIX=$HOME/TMP/install -DUNUSED_WARNINGS=FALSE -DUNINITIALIZED_WARNINGS=FALSE $CMAKE_OPTS $HOME/amber$version 

    make -j2
}

function install_ambertools_travis()
{
	# clang seems to break when GCC 5's headers are installed
	# in fact, you could say that it takes a header..... ba dum crash
	# anyway, we must only install the GCC 5 apt packages if we aren's using clang
	if [ "$COMPILER" = "gcc" ]
		CMAKE_OPTS="$CMAKE_OPTS -DCMAKE_C_COMPILER=gcc-5 -DCMAKE_CXX_COMPILER=g++-5 -DCMAKE_Fortran_COMPILER=gfortran-5"
		sudo apt-get -y install gcc-5 g++-5 gfortran-5
	elif [ "$COMPILER" = "clang" ]
		# must set CMAKE_Fortran_COMPILER_VERSION due to CMake bug #15372, whch was not fixed until CMake 3.3
		CMAKE_OPTS="$CMAKE_OPTS -DCOMPILER=clang -DCMAKE_Fortran_COMPILER_VERSION=4.6.4"
	fi
	
    set -ex

	build_ambertools
	make -j2 install
}

function install_ambertools_circleci(){
    build_ambertools
	make install
}

function run_long_test_simplified(){
    source $HOME/TMP/amber.sh
    # not running all tests, skip any long long test.
    cd $AMBERHOME/AmberTools/test
    python $HOME/amber.run_tests -t $TEST_TASK -x $HOME/EXCLUDED_TESTS
    # python $TRAVIS_BUILD_DIR/amber$version/AmberTools/src/conda_tools/amber.run_tests $TEST_TASK
}

function run_tests(){
    set -ex
    source $HOME/TMP/amber.sh
    ls $AMBERHOME
    ls $HOME/TMP/
    ls $HOME/TMP/*/
   
    if [ "$TEST_TASK" != "" ]; then
        run_long_test_simplified
    else
        if [ "$SKIP_PYTHON" != "True" ]; then
            cat $TRAVIS_BUILD_DIR/amber$version/AmberTools/src/conda-recipe/run_test.sh | sed "s/python/amber.python/g" > $HOME/run_test.sh
            bash $HOME/run_test.sh
        else
            (cd $AMBERHOME/AmberTools/test && make test.ambermini)
        fi
    fi
}
