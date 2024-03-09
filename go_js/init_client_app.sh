#!/bin/sh

START_DIR=$(pwd)

catch_err() {
  echo "ERR: $1"
  cd "$START_DIR" && exit 1
}

if [ -d "./client" ]; then
  # init client side env
  cd client || exit 1

  # create index.html in dist (bug: not pulling from git)
  if [ ! -d "./dist" ]; then
    mkdir dist
    echo '<!DOCTYPE html>
    <html lang="en">
    <head>
      <meta charset="UTF-8">
      <meta name="viewport" content="width=device-width, initial-scale=1.0">
      <title>Dude suh</title>
    </head>
    <body>
      <div id="root"></div>
      <script type="module" src="src/bundle.js"></script>
    </body>
    </html>' > dist/index.html
  else
    echo "dist folder was pulled from github! now safe to delete this conditional"
  fi

  pnpm i -D esbuild react react-dom || catch_err "Failed to install client dependencies"

  cd "$START_DIR" && exit 0
else
  catch_err "client dir not found"
fi
