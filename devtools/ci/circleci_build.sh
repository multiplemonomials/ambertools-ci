#!/bin/sh

source devtools/ci/load_functions.sh
# source code
download_ambertools

# binary
fn='AT.binary.tar.bz2'
url='https://circleci.com/api/v1.1/project/github/Amber-MD/ambertools-test/latest/artifacts?circle-token=$ATCITOKEN&branch=nightly&filter=successful'
wget $url -O $fn
mkdir TEST
cd TEST
tar -xf ../$fn
cd amber17
source amber.sh
mkdir test
cd test
lndir $HOME/amber17/test
cd $AMBERHOME/AmberTools
mkdir test
cd test
lndir $HOME/AmberTools/test
cd $AMBERHOME
touch config.h
touch $AMBERHOME/AmberTools/src/config.h
INSTALLTYPE make test
