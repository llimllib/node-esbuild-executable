# Making a single-file executable with node and esbuild

This repository elaborates on on node's [skimpy instructions](https://nodejs.org/api/single-executable-applications.html) by showing how you might bundle an app with multiple files and a dependency, and build it into an executable binary.

I wrote a guide [here](https://notes.billmill.org/programming/javascript/Making_a_single-file_executable_with_node_and_esbuild.html) that walks you step by step through how you might end up with something similar to the code in this repository.

## Building the code in this repository

On a mac or linux computer, execute `make` and you should end up with a `sum` binary in the `dist` folder, which will sum up all the numbers you pass to it.

For example:

```console
$ make
npx esbuild \
		--format=cjs \
		--target=node20 \
		--platform=node \
		--bundle \
		--outfile=dist/bundle.js \
		index.js

  dist/bundle.js  8.8kb

⚡ Done in 3ms
node --experimental-sea-config sea-config.json
Wrote single executable preparation blob to dist/sea-prep.blob
cp /Users/llimllib/.local/share/asdf/installs/nodejs/20.2.0/bin/node dist/rb
codesign --remove-signature dist/rb
npx postject dist/rb NODE_SEA_BLOB dist/sea-prep.blob \
		--sentinel-fuse NODE_SEA_FUSE_fce680ab2cc467b6e072b8b5df1996b2 \
		--macho-segment-name NODE_SEA 
Start injection of NODE_SEA_BLOB in dist/rb...
💉 Injection done!
codesign --sign - dist/rb

$ dist/sum 1 2 3 4
10
```

## TODO

- I would love to support windows! But I haven't used a windows computer in 20 years. Pull requests would be gladly accepted
