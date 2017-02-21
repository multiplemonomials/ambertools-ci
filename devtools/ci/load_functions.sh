#!/bin/sh

url="http://ambermd.org/downloads/ambertools-dev/AmberTools17.21feb17.tar.gz"
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
    python $HOME/ambertools-test/amber$version/AmberTools/src/conda-recipe/scripts/build_all.py --exclude-osx --py 2.7 --sudo
}

function run_long_test_simplified(){
    # not running all tests, skip any long long test.
    (cd $AMBERHOME/test/sanderapi && make)
    cd $AMBERHOME/AmberTools/test

    make clean
    make is_amberhome_defined
    make test.cpptraj
    make test.pytraj
    make test.parmed
    make test.pdb4amber
    make test.nab
    make test.antechamber
    make test.mdgx
    make test.leap
    make test.unitcell
    make test.resp
    make test.reduce
    make test.pbsa
    make test.gbnsr6
    make test.mmpbsa
    make test.elsize
    make test.sqm
    make test.paramfit
    make test.mm_pbsa
    make test.FEW
    make test.cphstats
    make test.charmmlipid2amber
    make test.cpinutil
    make test.pymsmt
}

function run_tests(){
    set -ex
    if [ "$USE_AMBER_PREFIX" = "True" ]; then
        source $HOME/TMP/amber.sh
    else
        source $TRAVIS_BUILD_DIR/amber$version/amber.sh
    fi
    if [ "$TEST_LONG" = "True" ]; then
        run_long_test_simplified
    else
        cat $TRAVIS_BUILD_DIR/amber$version/AmberTools/src/conda-recipe/run_test.sh | sed "s/python/amber.python/g" > $HOME/run_test.sh
        bash $HOME/run_test.sh
    fi
}
