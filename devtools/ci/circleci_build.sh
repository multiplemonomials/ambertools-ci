#!/bin/sh

sudo apt-get -y install flex

source devtools/ci/load_functions.sh
download_ambertools
install_ambertools_circleci
