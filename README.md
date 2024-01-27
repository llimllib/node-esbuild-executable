# makeing a single-file executable with node and esbuild

This repository elaborates on on node's [skimpy instructions](https://nodejs.org/api/single-executable-applications.html) for how to build an executable with an example that includes multiple files and a dependency:

(All this is on a mac. Instructions vary for your platform, but will be similar)

- `npm init -y` to create a new package
- let's install a package: `npm add --save minimist`
- enable ESM modules by adding `"type": "module"` to `package.json`
- Create a simple two-file program that uses our dependency, so we can simulate something vaguely realistic:

**sum.js**
```javascript
export function sum(ns) { return ns.reduce((x,y) => x+y, 0) }
```

**index.js**
```javascript
import minimist from "minimist";
import { sum } from "./sum.js";

sum(minimist(process.argv.slice(2))._)
```

We can test that this simple program works to sum the numbers input into it:

```console
$ node index.js 1 2 3 4
10
```

- Create an SEA config file. This tells node how to package your executable
**sea-config.json**
```javascript
{ 
  "main": "index.js", 
  "output": "sea-prep.blob"  
}
```

- Use the `--experimental-sea-config` flag to create a "blob". This is a bit of code that will get inserted into a node binary, to make it into a single executable that you can distribute. It will write the "blob" to the location you specified in the `output` field of `sea-config.json`
	- `node --experimental-sea-config sea-config.json`
- Copy a `node` executable to your directory, and give it the name of your desired executable. Here I've used `sum`:
	- Since node can be hidden by symlinks, this command grabs it from `asdf` or `nvm` if they're present
	- `cp $(asdf which node || nvm which node || command -v node) sum`
- remove the signature from the binary: `codesign --remove-signature sum`
- Insert the "blob" into the binary with [`postject`](https://www.npmjs.com/package/postject):
    ```bash
npx postject sum NODE_SEA_BLOB sea-prep.blob \
    --sentinel-fuse NODE_SEA_FUSE_fce680ab2cc467b6e072b8b5df1996b2 \
    --macho-segment-name NODE_SEA
    ```
- Re-sign the new binary: `codesign --sign - sum`
- Run the script, and note that it fails!

```
$ ./sum 1 2 3 4 5      
(node:39271) Warning: To load an ES module, set "type": "module" in the package.json or use the .mjs extension.
(Use `sea-example --trace-warnings ...` to show where the warning was created)
/private/tmp/test-sea/sea-example:1
import minimist from "minimist";
^^^^^^

SyntaxError: Cannot use import statement outside a module
    at internalCompileFunction (node:internal/vm:73:18)
    at wrapSafe (node:internal/modules/cjs/loader:1175:20)
    at embedderRunCjs (node:internal/util/embedding:18:27)
    at node:internal/main/embedding:18:34

Node.js v20.2.0
```

## bundling it all up

There's (at least) two problems with the binary we built:
- it doesn't include the `minimist` library which is a dependency of our script
- our code inside the binary is attempting to load an ES module, which seems to be unsupported in a SEA program
	- This is not noted in the documentation! I'd love to know if this is actually the case

We can fix both of these problems by using [esbuild](https://esbuild.github.io/) to bundle up our code with its dependencies, and convert it into a cjs module that will work correctly in our binary.

-  install esbuild: `npm add --save-dev esbuild`
-  run esbuild to create a bundle, and save it to `bundle.js`:
	```
	npx esbuild \
		--format=cjs \
		--target=node20 \
		--platform=node \
		--bundle \
		--outfile=bundle.js \ 
		index.js
	```
- Now we're ready to re-build our "blob" file:
	- `node --experimental-sea-config sea-config.json`
- copy a fresh node into our directory:
	- `cp $(asdf which node || nvm which node || command -v node) sum`
- remove the signature:
	- `codesign --remove-signature sum`
- insert the "blob":
    ```bash
npx postject sum NODE_SEA_BLOB sea-prep.blob \
    --sentinel-fuse NODE_SEA_FUSE_fce680ab2cc467b6e072b8b5df1996b2 \
    --macho-segment-name NODE_SEA
    ```
- and re-sign our binary:
	- `codesign --sign - sum`

This time, it works!

```console
$ ./sum 1 2 3 4        
10
(node:44573) ExperimentalWarning: Single executable application is an experimental feature and might change at any time
(Use `sum --trace-warnings ...` to show where the warning was created)

# `sum` is an executable binary:
$ file sum
sum: Mach-O 64-bit executable arm64

# that weighs 82 megabytes:
$ ls -alh sum
-rwxr-xr-x@ 1 llimllib  staff    82M Jan 27 16:11 sum*
```
