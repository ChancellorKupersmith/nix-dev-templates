#!/bin/sh

START_DIR=$(pwd)

catch_err() {
  echo "ERR: $1"
  cd "$START_DIR" && exit 1
}

if [ -d "./client" ]; then
  # init client side env
  cd client || exit 1

  pnpm i -D esbuild react react-dom || catch_err "Failed to install client dependencies"

  cd "$START_DIR" && exit 0
else
  catch_err "client dir not found"
fi
