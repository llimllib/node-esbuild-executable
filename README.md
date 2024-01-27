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

## Why make?

Because it's still great at what it was meant to do: build binaries out of source files when they change.

## TODO

- I would love to support windows! But I haven't used a windows computer in 20 years. Pull requests would be gladly accepted
- I'd also love ideas about how to make the binary any smaller than its current weight of 82 megabytes
