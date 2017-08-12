#!/bin/bash
# Copyright (c) 2015-present, Facebook, Inc.
# All rights reserved.
#
# This source code is licensed under the BSD-style license found in the
# LICENSE file in the root directory of this source tree. An additional grant
# of patent rights can be found in the PATENTS file in the same directory.

# ******************************************************************************
# This is an end-to-end test intended to run on CI.
# You can also run it locally but it's slow.
# ******************************************************************************

# Start in tasks/ even if run from root directory
cd "$(dirname "$0")"

# CLI and app temporary locations
# http://unix.stackexchange.com/a/84980
temp_app_path=`mktemp -d 2>/dev/null || mktemp -d -t 'temp_app_path'`

function cleanup {
  echo 'Cleaning up.'
  cd "$root_path"
  rm -rf $temp_app_path
}

# Error messages are redirected to stderr
function handle_error {
  echo "$(basename $0): ERROR! An error was encountered executing line $1." 1>&2;
  cleanup
  echo 'Exiting with error.' 1>&2;
  exit 1
}

function handle_exit {
  cleanup
  echo 'Exiting without error.' 1>&2;
  exit
}

function create_react_app {
  if [ "$USE_YARN" = "yes" ]
  then
    yarn create react-app -- "$@"
  else
    create-react-app "$@"
  fi
}

# Check for the existence of one or more files.
function exists {
  for f in $*; do
    test -e "$f"
  done
}

# Exit the script with a helpful error message when any error is encountered
trap 'set +x; handle_error $LINENO $BASH_COMMAND' ERR

# Cleanup before exit on any termination signal
trap 'set +x; handle_exit' SIGQUIT SIGTERM SIGINT SIGKILL SIGHUP

# Echo every command being executed
set -x

# Go to root
cd ..
root_path=$PWD

# Clear cache to avoid issues with incorrect packages being used
if hash yarnpkg 2>/dev/null
then
  # AppVeyor uses an old version of yarn.
  # Once updated to 0.24.3 or above, the workaround can be removed
  # and replaced with `yarnpkg cache clean`
  # Issues:
  #    https://github.com/yarnpkg/yarn/issues/2591
  #    https://github.com/appveyor/ci/issues/1576
  #    https://github.com/facebookincubator/create-react-app/pull/2400
  # When removing workaround, you may run into
  #    https://github.com/facebookincubator/create-react-app/issues/2030
  case "$(uname -s)" in
    *CYGWIN*|MSYS*|MINGW*) yarn=yarn.cmd;;
    *) yarn=yarnpkg;;
  esac
  $yarn cache clean
fi

if hash npm 2>/dev/null
then
  # npm 5 is too buggy right now
  if [ $(npm -v | head -c 1) -eq 5 ]; then
    npm i -g npm@^4.x
  fi;
  npm cache clean || npm cache verify
fi

# If the node version is < 6, the script should just give an error.
nodeVersion=`node --version | cut -d v -f2`
nodeMajor=`echo $nodeVersion | cut -d. -f1`
nodeMinor=`echo $nodeVersion | cut -d. -f2`
if [[ nodeMajor -lt 6 ]]
then
  cd $temp_app_path
  err_output=`node "$root_path"/packages/create-react-app/index.js test-node-version 2>&1 > /dev/null || echo ''`
  [[ $err_output =~ You\ are\ running\ Node ]] && exit 0 || exit 1
fi

if [ "$USE_YARN" = "yes" ]
then
  # Install Yarn so that the test can use it to install packages.
  npm install -g yarn
  yarn cache clean
else
  npm install -g create-react-app
fi

# ******************************************************************************
# Pack react-scripts so we can verify they work.
# ******************************************************************************

scripts_path="$root_path"/`npm pack`

# ******************************************************************************
# Now that we have packed them, create a clean app folder and install them.
# ******************************************************************************

# Install the app in a temporary location
cd $temp_app_path
create_react_app --scripts-version="$scripts_path" test-app

# ******************************************************************************
# Now that we used create-react-app to create an app depending on react-scripts,
# let's make sure all npm scripts are in the working state.
# ******************************************************************************

function verify_env_url {
  # Backup package.json because we're going to make it dirty
  cp package.json package.json.orig

  # Test default behavior
  grep -F -R --exclude=*.map "\"/static/" build/ -q; test $? -eq 0 || exit 1

  # Test relative path build
  awk -v n=2 -v s="  \"homepage\": \".\"," 'NR == n {print s} {print}' package.json > tmp && mv tmp package.json

  npm run build
  # Disabled until this can be tested
  # grep -F -R --exclude=*.map "../../static/" build/ -q; test $? -eq 0 || exit 1
  grep -F -R --exclude=*.map "\"./static/" build/ -q; test $? -eq 0 || exit 1
  grep -F -R --exclude=*.map "\"/static/" build/ -q; test $? -eq 1 || exit 1

  PUBLIC_URL="/anabsolute" npm run build
  grep -F -R --exclude=*.map "/anabsolute/static/" build/ -q; test $? -eq 0 || exit 1
  grep -F -R --exclude=*.map "\"/static/" build/ -q; test $? -eq 1 || exit 1

  # Test absolute path build
  sed "2s/.*/  \"homepage\": \"\/testingpath\",/" package.json > tmp && mv tmp package.json

  npm run build
  grep -F -R --exclude=*.map "/testingpath/static/" build/ -q; test $? -eq 0 || exit 1
  grep -F -R --exclude=*.map "\"/static/" build/ -q; test $? -eq 1 || exit 1

  PUBLIC_URL="https://www.example.net/overridetest" npm run build
  grep -F -R --exclude=*.map "https://www.example.net/overridetest/static/" build/ -q; test $? -eq 0 || exit 1
  grep -F -R --exclude=*.map "\"/static/" build/ -q; test $? -eq 1 || exit 1
  grep -F -R --exclude=*.map "testingpath/static" build/ -q; test $? -eq 1 || exit 1

  # Test absolute url build
  sed "2s/.*/  \"homepage\": \"https:\/\/www.example.net\/testingpath\",/" package.json > tmp && mv tmp package.json

  npm run build
  grep -F -R --exclude=*.map "/testingpath/static/" build/ -q; test $? -eq 0 || exit 1
  grep -F -R --exclude=*.map "\"/static/" build/ -q; test $? -eq 1 || exit 1

  PUBLIC_URL="https://www.example.net/overridetest" npm run build
  grep -F -R --exclude=*.map "https://www.example.net/overridetest/static/" build/ -q; test $? -eq 0 || exit 1
  grep -F -R --exclude=*.map "\"/static/" build/ -q; test $? -eq 1 || exit 1
  grep -F -R --exclude=*.map "testingpath/static" build/ -q; test $? -eq 1 || exit 1

  # Restore package.json
  rm package.json
  mv package.json.orig package.json
}

function verify_module_scope {
  # Save app.re, we're going to modify it
  cp src/app.re src/app.re.bak

  # Add an out of scope import
  echo "open Nonexistent;" | cat - src/app.re > src/app.re.temp && mv src/app.re.temp src/app.re

  # Make sure the build fails
  npm run build; test $? -eq 1 || exit 1
  # TODO: check for error message

  # Restore app.re
  rm src/app.re
  mv src/app.re.bak src/app.re
  rm -rf lib
}

# Enter the app directory
cd test-app

# Test the build
npm run build
# Check for expected output
exists build/*.html
exists build/static/js/*.js
exists build/static/css/*.css
exists build/static/media/*.svg
exists build/favicon.ico

# Run tests with CI flag
CI=true npm test

# Test the server
npm start -- --smoke-test

# Test environment handling
verify_env_url

# Test reliance on webpack internals
verify_module_scope

# ******************************************************************************
# Finally, let's check that everything still works after ejecting.
# ******************************************************************************

# Eject...
echo yes | npm run eject

# Test the build
npm run build
# Check for expected output
exists build/*.html
exists build/static/js/*.js
exists build/static/css/*.css
exists build/static/media/*.svg
exists build/favicon.ico

# Run tests, overring the watch option to disable it.
# Until we upgrade to Jest 20 there's a bug in `node scripts/test.js` related
# to argv.
sed -i -e 's/jest.run(argv);/jest.run.apply(null, argv);/' scripts/test.js
npm test -- --watch=no

# Test the server
npm start -- --smoke-test

# Test environment handling
verify_env_url

# Test reliance on webpack internals
verify_module_scope

# Cleanup
cleanup
