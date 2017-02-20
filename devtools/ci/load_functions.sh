#!/bin/sh

version=17

function download_ambertools(){
    tarfile="AmberTools17.20feb17.tar.bz2"
    url="https://www.dropbox.com/s/t3uudgldmun2lh7/$tarfile?dl=1"
    wget $url -O $tarfile
    tar -xf $tarfile
}

function install_ambertools_travis(){
    set -ex
    # This AmberTools version is not an official release. It is meant for testing.
    # DO NOT USE IT PLEASE.
    cd amber$version
    if [ "MINICONDA_WILL_BE_INSTALLED" = "True" ]; then
        yes | ./configure gnu
    elif [ "MINICONDA_IN_AMBERHOME" = "True" ]; then
        bash AmberTools/src/configure_python --prefix `pwd`
        ./configure gnu
    elif [ "USE_WITH_PYTHON" = "True" ]; then
        bash AmberTools/src/configure_python --prefix $HOME
        export PATH=$HOME/miniconda/bin:$PATH
        ./configure --with-python $HOME/miniconda/bin/python gnu
    elif [ "SKIP_PYTHON" = "True" ]; then
        ./configure --skip-python gnu
        source amber.sh # for nab
    elif [ "PYTHON_VERSION" = "3.5" ]; then
        bash AmberTools/src/configure_python --prefix $HOME -v $PYTHON_VERSION
        export PATH=$HOME/miniconda/bin:$PATH
        ./configure --with-python $HOME/miniconda/bin/python gnu
    fi
    make install -j2
}

function install_ambertools_circleci(){
    mkdir $HOME/TMP
    cd $HOME/TMP
    python $HOME/ambertools-test/amber$version/AmberTools/src/conda-recipe/scripts/build_all.py --exclude-osx --py 2.7
}
