[![Build Status](https://travis-ci.org/hainm/ambertools-test.svg?branch=at17)](https://travis-ci.org/hainm/ambertools-test)
[![CircleCI](https://circleci.com/gh/hainm/ambertools-test.svg?style=svg)](https://circleci.com/gh/hainm/ambertools-test)

# ambertools-test
For testing AmberTools

# How to run your own change?
- make your own AmberTools17.{date}.tar.gz file
```bash
    cd $AMBERHOME
    sh ./mkrelease_at
    # then upload to somewhere
```
- update AmberTools17 url in [devtools/ci/load_functions.sh](devtools/ci/load_functions.sh)
- update your own test in [devtools/ci/load_functions.sh](devtools/ci/load_functions.sh)
- make a pull request to this repo or [activate your travis account](https://travis-ci.org/getting_started)
