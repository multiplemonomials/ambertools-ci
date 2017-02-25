#!/bin/sh

devtools_ci_dir=`cd $(dirname $0) && pwd`

source devtools/ci/load_functions.sh
# source code
download_ambertools

amber_source=$HOME/ambertools-test/amber17

# binary
fn='AT.binary.tar.bz2'
url='https://96-81537431-gh.circle-artifacts.com/0/tmp/circle-artifacts.bQx72o3/ambertools-build/amber-conda-bld/non-conda-install/linux-64.ambertools-17.0.0-py27_0.25Feb17.H0711.tar.bz2'
wget $url -O $fn
mkdir TEST
cd TEST
tar -xf ../$fn
cd amber17
source amber.sh
cp $amber_source/Makefile .
mkdir test
cd test
lndir $amber_source/test >& log.lndir
mkdir -p $AMBERHOME/AmberTools/test
cd $AMBERHOME/AmberTools/test
lndir $amber_source/AmberTools/test >& log.lndirt2

cd $AMBERHOME
sh bin/configure_python --prefix $AMBERHOME
which amber.python
cat > config.h <<EOF
INSTALLTYPE=serial
AMBER_SOURCE=$amber_source
PYTHON=amber.python
EOF

mkdir -p $AMBERHOME/AmberTools/src
cp config.h $AMBERHOME/AmberTools/src/
python $devtools_ci_dir/ci_test.py
