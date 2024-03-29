NODE_BIN ?= $(shell asdf which node 2>/dev/null || nvm which node 2>/dev/null || command -v node)
UNAME_S := $(shell uname -s)
JS_FILES := $(shell git ls-files '*.js')

# build the `sum` binary
#
# https://nodejs.org/api/single-executable-applications.html
#
# $@ means "the name of this target", which is "dist/sum" in this case
dist/sum: dependencies dist/bundle.js
	node --experimental-sea-config sea-config.json
	cp $(NODE_BIN) $@
	strip $@
ifeq ($(UNAME_S),Darwin)
	codesign --remove-signature $@
	npx postject $@ NODE_SEA_BLOB dist/sea-prep.blob \
		--sentinel-fuse NODE_SEA_FUSE_fce680ab2cc467b6e072b8b5df1996b2 \
		--macho-segment-name NODE_SEA 
	codesign --sign - $@
else
	npx postject $@ NODE_SEA_BLOB dist/sea-prep.blob \
		--sentinel-fuse NODE_SEA_FUSE_fce680ab2cc467b6e072b8b5df1996b2
endif

# Create a bundled version of the app, so that we can build an executable out
# of it.
dist/bundle.js: $(JS_FILES)
	npx esbuild \
		--format=cjs \
		--target=node20 \
		--platform=node \
		--bundle \
		--outfile=$@ \
		index.js

# an example of how to build a similar executable with the bun runtime
# https://bun.sh/
# https://bun.sh/docs/bundler
dist/sum_bun: dependencies
	bun build --compile index.js --outfile $@

dist/sum_deno:
	deno compile \
		--node-modules-dir=false \
		-o dist/sum_deno \
		./deno/index.js

.PHONY: dependencies
dependencies:
	npm i

.PHONY: clean
clean:
	rm dist/*

.PHONY: time_builds
time_builds:
	node --version
	time $(MAKE) dist/sum
	bun --version
	time $(MAKE) dist/sum_bun
	deno --version
	time $(MAKE) dist/sum_deno

.PHONY: bench
bench: clean time_builds
	hyperfine "dist/sum {1..10000}"
	hyperfine "dist/sum_bun {1..10000}"
	hyperfine "dist/sum_deno {1..10000}"
	ls -alh dist/sum*

# to test on linux, build the dockerfile and run it; it should output "10"
# after a whole bunch of building output
.PHONY: test-on-linux
test-on-linux:
	docker build -t sum . && \
		docker run --rm sum
