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
        elif [ "$PYTHON_VERSION" = "3.5" ]; then
            bash AmberTools/src/configure_python --prefix $HOME -v $PYTHON_VERSION
            export PATH=$HOME/miniconda/bin:$PATH
            ./configure --with-python $HOME/miniconda/bin/python gnu
        fi
    fi
    make install -j2
}

function install_ambertools_circleci(){
    mkdir $HOME/TMP
    cd $HOME/TMP
    python $HOME/ambertools-test/amber$version/AmberTools/src/conda-recipe/scripts/build_all.py --exclude-osx --py 2.7
}

function run_tests(){
    set -ex
    if [ "$USE_AMBER_PREFIX" = "True" ]; then
        source $HOME/TMP/amber$version/amber.sh
    else
        source $HOME/amber$version/amber.sh
    fi
    source $HOME/amber$version/AmberTools/src/conda-recipe/run_tests.sh
}
