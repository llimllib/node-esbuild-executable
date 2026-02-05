# Making a single-file executable with node and esbuild

This repository elaborates on on node's [skimpy instructions](https://nodejs.org/api/single-executable-applications.html) by showing how you might bundle an app with multiple files and a dependency, and build it into an executable binary.

**update feb 4 2025**: Joyee Cheung [greatly simplified the process](https://joyeecheung.github.io/blog/2026/01/26/improving-single-executable-application-building-for-node-js/). Great work! I've updated the build process, which will no longer work for node versions below **25.5.0**. In the process of updating I did hit [one bug](https://github.com/nodejs/node/issues/61579)

I wrote a guide [here](https://notes.billmill.org/programming/javascript/Making_a_single-file_executable_with_node_and_esbuild.html) that walks you step by step through how you might end up with something similar to the code in this repository.

This repository's main addition to that article is a simple `Makefile` that will build the executable binary into `dist/sum` on either mac or linux.

- [Building the code in this repository](#building-the-code-in-this-repository)
- [Stripping the binary](#stripping-the-binary)
- [Benchmarks](#benchmarks)
- [Comparison with bun](#comparison-with-bun)
- [Comparison with deno](#comparison-with-deno)
- [Why use make?](#why-use-make)
- [TODO](#todo)

## Building the code in this repository

On a mac or linux computer:

- clone this repository and cd into it
- execute `make`

You should end up with a `sum` binary in the `dist` folder, which will be an executable file that sums up all the numbers you pass to it.

For example:

```console
$ make
npm i

up to date, audited 6 packages in 466ms

1 package is looking for funding
  run `npm fund` for details

1 moderate severity vulnerability

To address all issues (including breaking changes), run:
  npm audit fix --force

Run `npm audit` for details.
npx esbuild \
		--format=cjs \
		--target=node20 \
		--platform=node \
		--bundle \
		--outfile=dist/bundle.js \
		index.js

  dist/bundle.js  8.8kb

⚡ Done in 2ms
echo '{ "main": "dist/bundle.js", "output": "dist/sum", "executable": "/Users/llimllib/.local/share/mise/installs/node/25.6.0/bin/node", "disableExperimentalSEAWarning": true }' > sea-config.json
node --build-sea sea-config.json
Generated single executable /Users/llimllib/.local/share/mise/installs/node/25.6.0/bin/node + sea-config.json -> dist/sum
strip dist/sum
codesign --remove-signature dist/sum
codesign --sign - dist/sum

$ dist/sum 1 2 3 4
10

# the file's not small, but at least it works!
$ ls -lah dist/sum
.rwxr-xr-x   93M llimllib  4 Feb 23:10  󰡯  dist/sum
```

## Stripping the binary

Using [`strip`](https://www.man7.org/linux/man-pages/man1/strip.1.html) to remove debug symbols from the node binary results in a binary that is 66 megabytes instead of 82 on my local computer, with node v20.2.0.

In the [container provided in this repo](https://github.com/llimllib/node-esbuild-executable/blob/d7a6db6083a16732e9995ed824090f131496d2e3/Dockerfile), it saves about 16mb on the binary.

**I'm not sure this is safe to do in general**, but it works in this case and saves some space so I've [put it in the Makefile](https://github.com/llimllib/node-esbuild-executable/blob/004bfbe97e0d4e516e2d8665003772e95678b150/Makefile#L13). If you see adverse effects with it, or you want to debug your binary with `gdb` or `lldb`, you may want to remove it.

## Benchmarks

`make bench` will run the compilation processes for `node`, `bun`, and `deno` and report build time, the reuslt of a benchmark, and file size.

On my system (Macbook Pro with M1 Max and 32gb ram), which I should emphasize **is not set up to do proper benchmarking** so take this whith a large pile of salt, I get:

| interpreter | version | build (ms) | size (mb) | execution time   |
| ----------- | ------- | ---------- | --------- | ---------------- |
| node        | 25.6.0  | 2890       | 93        | 34.1 ms ± 0.9 ms |
| bun         | 1.3.8   | 600        | 57        | 18.6 ms ± 0.7 ms |
| deno        | 2.6.8   | 790        | 72        | 32.4 ms ± 0.5 ms |
