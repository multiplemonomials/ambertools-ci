#!/bin/sh

url="http://ambermd.org/downloads/ambertools-dev/AmberTools17.tar.gz"
tarfile=`python -c "url='$url'; print(url.split('/')[-1])"`
version=`python -c "tarfile='$tarfile'; print(tarfile.split('.')[0][-2:])"`

function download_ambertools(){
    wget $url -O $tarfile
    tar -xf $tarfile
}

function install_ambertools_travis(){
    set -ex
    # This AmberTools version is not an official release. It is meant for testing.
    # DO NOT USE IT PLEASE.
    osname=`python -c 'import sys; print(sys.platform)'`
    cd amber$version
    if [ $osname = "darwin" ]; then
        bash AmberTools/src/configure_python --prefix $HOME -v $PYTHON_VERSION
        export PATH=$HOME/miniconda/bin:$PATH
        ./configure --with-python $HOME/miniconda/bin/python -macAccelerate clang
    else
        if [ "$MINICONDA_WILL_BE_INSTALLED" = "True" ]; then
            yes | ./configure gnu
        elif [ "$MINICONDA_IN_AMBERHOME" = "True" ]; then
            bash AmberTools/src/configure_python --prefix `pwd`
            ./configure gnu
        elif [ "$USE_AMBER_PREFIX" = "True" ]; then
            mkdir $HOME/TMP/
            yes | ./configure --prefix $HOME/TMP gnu
        elif [ "$USE_WITH_PYTHON" = "True" ]; then
            bash AmberTools/src/configure_python --prefix $HOME
            export PATH=$HOME/miniconda/bin:$PATH
            ./configure --with-python $HOME/miniconda/bin/python gnu
        elif [ "$SKIP_PYTHON" = "True" ]; then
            ./configure --skip-python gnu
        elif [ "$AMBER_INSTALL_MPI" = "True" ]; then
            yes | ./configure gnu
            make install -j2
            ./configure -mpi gnu # will do make install later
        elif [ "$PYTHON_VERSION" = "3.5" ]; then
            bash AmberTools/src/configure_python --prefix $HOME -v 3
            export PATH=$HOME/miniconda/bin:$PATH
            ./configure --with-python $HOME/miniconda/bin/python gnu
        fi
    fi
    make install -j2
}

function install_ambertools_circleci(){
    mkdir $HOME/TMP
    cd $HOME/TMP
    python $HOME/ambertools-test/amber$version/AmberTools/src/conda_tools/build_all.py --exclude-osx -t ambertools_pack_all_pythons --sudo
    # python $HOME/ambertools-test/amber$version/AmberTools/src/conda-recipe/scripts/build_all.py --exclude-osx --py 2.7 --sudo -t ambermini
}

function run_long_test_simplified(){
    # not running all tests, skip any long long test.
    cd $AMBERHOME/AmberTools/test
    python $TRAVIS_BUILD_DIR/devtools/ci/ci_test.py
}

function circleci_test(){
    # install conda
    bash $HOME/ambertools-test/amber$version/AmberTools/src/configure_python --prefix $HOME
    export PATH=$HOME/miniconda/bin:$PATH
    python $HOME/ambertools-test/amber$version/AmberTools/src/conda_tools/test_multiple_pythons.py
}

function run_tests(){
    set -ex
    if [ "$USE_AMBER_PREFIX" = "True" ]; then
        source $HOME/TMP/amber.sh
        ls $AMBERHOME
        ls $HOME/TMP/
        ls $HOME/TMP/*/
    else
        source $TRAVIS_BUILD_DIR/amber$version/amber.sh
    fi
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
