import * as esbuild from 'esbuild'

let ctx = await esbuild.context({
  entryPoints: ['src/app.jsx'],
  outfile: 'dist/src/bundle.js',
  bundle: true,
  sourcemap: true,
})

await ctx.watch()

let { host, port } = await ctx.serve({
  servedir: 'dist',
})
