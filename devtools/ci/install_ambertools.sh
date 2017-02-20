#!/bin/sh

function download_ambertools(){
    version="AmberTools17.20feb17.tar.bz2"
    url="https://www.dropbox.com/s/t3uudgldmun2lh7/$version?dl=1"
    wget $url -O $version
    tar -xf $version
}

function install_ambertools(){
    set -ex
    # This AmberTools version is not an official release. It is meant for testing.
    # DO NOT USE IT PLEASE.
    cd amber17
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
