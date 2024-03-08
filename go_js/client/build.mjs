import * as esbuild from 'esbuild'

let result = await esbuild.build({
  entryPoints: ['src/app.jsx'],
  bundle: true,
  minify: true,
  outfile: 'dist/src/bundle.js',
})
console.log(result)
