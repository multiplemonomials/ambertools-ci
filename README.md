[![Build Status](https://travis-ci.org/hainm/ambertools-test.svg?branch=at17)](https://travis-ci.org/hainm/ambertools-test)
[![CircleCI](https://circleci.com/gh/hainm/ambertools-test.svg?style=svg)](https://circleci.com/gh/hainm/ambertools-test)

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
