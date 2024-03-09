#!/bin/sh

START_DIR=$(pwd)

catch_err() {
  echo "ERR: $1"
  cd "$START_DIR" && exit 1
}

if [ -d "./server" ]; then
  cd server || exit 1
  go install
  # save built executable as var
  export server="$HOME/go/bin/server"
else
  catch_err "couldn't find server directory."
fi

cd "$START_DIR" && exit 0
