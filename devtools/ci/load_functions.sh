#!/bin/bash -x

url="https://app.box.com/shared/static/yyizddvjrpchrhrnp55mhnnlyfd5xn06.bz2"
tarfile=AmberTools.tar.bz2
version='16'
EXCLUDED_TESTS=test.parmed
AMBERTOOLS_VERSION=18.0

function download_ambertools(){
    wget $url -O $tarfile
    tar -xf $tarfile
}

function install_ambertools_travis(){
    set -ex
    
	mkdir -p $HOME/TMP/build
    cd $HOME/TMP/build
	
    osname=`python -c 'import sys; print(sys.platform)'`	
	# build CMake command line from options
    if [ $osname = "darwin" ]; then
        compiler="clang"
    else
        compiler="gnu"
    fi
    if [ "$MINICONDA_WILL_BE_INSTALLED" != "True" ]; then
        miniconda_opt="-DUSE_MINICONDA=TRUE"
    elif [ "$AMBER_INSTALL_MPI" = "True" ]; then
        mpi_opt="-DMPI=TRUE"
    fi
	
    cmake -DCMAKE_INSTALL_PREFIX=$HOME/TMP -DCOMPILER=$compiler $miniconda_opt $mpi_opt $HOME/ambertools-ci/amber$version 
    make install -j2
}

function install_ambertools_circleci(){
    mkdir -p $HOME/TMP/build
    cd $HOME/TMP/build
    cmake $HOME/ambertools-ci/amber$version -DCMAKE_INSTALL_PREFIX=$HOME/TMP
	make -j2
	make install
}

function run_long_test_simplified(){
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
