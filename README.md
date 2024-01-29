# Making a single-file executable with node and esbuild

This repository elaborates on on node's [skimpy instructions](https://nodejs.org/api/single-executable-applications.html) by showing how you might bundle an app with multiple files and a dependency, and build it into an executable binary.

I wrote a guide [here](https://notes.billmill.org/programming/javascript/Making_a_single-file_executable_with_node_and_esbuild.html) that walks you step by step through how you might end up with something similar to the code in this repository.

This repository's main addition to that article is a simple `Makefile` that will build the executable binary into `dist/sum` on either mac or linux.

## Building the code in this repository

On a mac or linux computer:

- clone this repository and cd into it
- execute `make`

You should end up with a `sum` binary in the `dist` folder, which will be an executable file that sums up all the numbers you pass to it.

For example:

```console
$ make
npm i

up to date, audited 4 packages in 618ms

1 package is looking for funding
  run `npm fund` for details

found 0 vulnerabilities
node --experimental-sea-config sea-config.json
Wrote single executable preparation blob to dist/sea-prep.blob
cp /Users/llimllib/.local/share/asdf/installs/nodejs/20.2.0/bin/node dist/sum
codesign --remove-signature dist/sum
npx postject dist/sum NODE_SEA_BLOB dist/sea-prep.blob \
		--sentinel-fuse NODE_SEA_FUSE_fce680ab2cc467b6e072b8b5df1996b2 \
		--macho-segment-name NODE_SEA 
Start injection of NODE_SEA_BLOB in dist/sum...
💉 Injection done!
codesign --sign - dist/sum

$ dist/sum 1 2 3 4
10

# the file's not small, but at least it works!
$ ls -alh dist/sum
-rwxr-xr-x@ 1 llimllib  staff    82M Jan 27 16:24 dist/sum*
```

## Comparison with bun

You can build a binary with [bun](https://bun.sh/docs/bundler#target), if you have it installed, by running `make dist/sum_bun`

**Pros**
- faster to build
- much simpler build command
- executable is 46mb, vs 82mb for node
- the executable runs about twice as fast on my system

```
$ hyperfine "dist/sum 1 2 3 4"           
Benchmark 1: dist/sum 1 2 3 4
  Time (mean ± σ):     147.4 ms ± 389.5 ms    [User: 19.8 ms, System: 5.1 ms]
  Range (min … max):    23.6 ms … 1255.8 ms    10 runs
 
  Warning: The first benchmarking run for this command was significantly slower than the rest (1.256 s). This could be caus
ed by (filesystem) caches that were not filled until after the first run. You should consider using the '--warmup' option t
o fill those caches before the actual benchmark. Alternatively, use the '--prepare' option to clear the caches before each 
timing run.
 
$ hyperfine "dist/sum_bun 1 2 3 4"
Benchmark 1: dist/sum_bun 1 2 3 4
  Time (mean ± σ):      73.6 ms ± 195.7 ms    [User: 6.6 ms, System: 5.9 ms]
  Range (min … max):    10.8 ms … 630.6 ms    10 runs
 
  Warning: The first benchmarking run for this command was significantly slower than the rest (630.6 ms). This could be cau
sed by (filesystem) caches that were not filled until after the first run. You should consider using the '--warmup' option 
to fill those caches before the actual benchmark. Alternatively, use the '--prepare' option to clear the caches before each
 timing run.
```

**Cons**
- bun is a rapidly evolving distribution and still has bugs in its node compatibility

## Comparison with deno

You can build a deno version of this binary with `make dist/sum_deno`, which runs `deno compile -o dist/sum_deno ./deno/index.js`

**Pros**

- much simpler compilation command

**Cons**

- the resulting binary is very large (104mb)
  - (did I do something wrong?)
- the resulting binary is slower than the node executable, and much slower than the bun executable:

```
$ hyperfine "dist/sum_deno 1 2 3 4"
Benchmark 1: dist/sum_deno 1 2 3 4
  Time (mean ± σ):     172.8 ms ± 478.6 ms    [User: 13.9 ms, System: 7.4 ms]
  Range (min … max):    20.2 ms … 1534.8 ms    10 runs
 
  Warning: The first benchmarking run for this command was significantly slower than the rest (1.535 s). This could be caused by (filesystem) caches that were not filled until after the first run. You should consider using the '--warmup' option to fill those caches before the actual benchmark. Alternatively, use the '--prepare' option to clear the caches before each tim ing run.
```

## Why use make?

Because it's still great at what it was meant to do: build binaries out of source files when they change.

## TODO

- I would love to support windows! But I haven't used a windows computer in 20 years. Pull requests would be gladly accepted
- I'd also love ideas about how to make the binary any smaller than its current weight of 82 megabytes
- add a demo of [bytecode compiling](https://github.com/nodejs/single-executable/issues/66#issuecomment-1517250431) with [bytenode](https://www.npmjs.com/package/bytenode)
