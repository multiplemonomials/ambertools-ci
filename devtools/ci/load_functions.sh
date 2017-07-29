#!/bin/bash

url="https://app.box.com/shared/static/9lgbqvjrxhls1p9avhi718vn8vfrfurq.bz2"
tarfile=AmberTools.tar.bz2
version='16'
EXCLUDED_TESTS=test.parmed
AMBERTOOLS_VERSION=18.0

function download_ambertools(){
	cd $HOME
    wget $url -O $tarfile
    tar -xf $tarfile
	
	echo "Contents of $HOME: "
	ls
}

function build_ambertools(){
    
	mkdir -p $HOME/TMP/build
    cd $HOME/TMP/build
	# we must run CMake twice because of the Fortran-compiler-version-not-being-autodetected bug in CMake 3.2
    cmake -DCMAKE_INSTALL_PREFIX=$HOME/TMP/install -DUNUSED_WARNINGS=FALSE -DUNINITIALIZED_WARNINGS=FALSE $CMAKE_OPTS $HOME/amber$version || echo "************************\nthis was supposed to fail\n************************"
	cmake -DCMAKE_INSTALL_PREFIX=$HOME/TMP/install -DUNUSED_WARNINGS=FALSE -DUNINITIALIZED_WARNINGS=FALSE $CMAKE_OPTS $HOME/amber$version 

    make -j2
}

function install_ambertools_travis(){
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
