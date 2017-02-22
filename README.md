[![Build Status](https://travis-ci.org/Amber-MD/ambertools-test.svg?branch=nightly)](https://travis-ci.org/Amber-MD/ambertools-test)
[![CircleCI](https://circleci.com/gh/Amber-MD/ambertools-test/tree/nightly.svg?style=svg)](https://circleci.com/gh/Amber-MD/ambertools-test/tree/nightly)

# ambertools-test
For testing AmberTools

# How to run your own change?
1. make your own AmberTools17.{date}.tar.gz file
```bash
    cd $AMBERHOME
    sh ./mkrelease_at # about 5 minutes
    # then upload to somewhere
```
2. update AmberTools17 url in [devtools/ci/load_functions.sh](devtools/ci/load_functions.sh)
3. update your own test in [run_tests function](devtools/ci/load_functions.sh)
4. make a pull request to this repo or [activate your travis account](https://travis-ci.org/getting_started)
