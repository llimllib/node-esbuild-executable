UNAME_S := $(shell uname -s)
JS_FILES := $(shell git ls-files '*.js')

# build the `sum` binary
#
# https://nodejs.org/api/single-executable-applications.html
#
# $@ means "the name of this target", which is "dist/sum" in this case
dist/sum: package-lock.json dist/bundle.js
	echo '{ "main": "dist/bundle.js", "output": "$@", "executable": "$(shell which node)", "disableExperimentalSEAWarning": true }' > sea-config.json
	node --build-sea sea-config.json
	strip $@
ifeq ($(UNAME_S),Darwin)
	codesign --sign - $@
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
dist/sum_bun: package-lock.json
	bun build --compile index.js --outfile $@

dist/sum_deno:
	deno compile \
		--node-modules-dir=false \
		-o dist/sum_deno \
		./deno/index.js

package-lock.json: package.json
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
	hyperfine -w3 "dist/sum {1..10000}" "dist/sum_bun {1..10000}" "dist/sum_deno {1..10000}"
	ls -alh dist/sum*

# to test on linux, build the dockerfile and run it; it should output "10"
# after a whole bunch of building output
.PHONY: test-on-linux
test-on-linux:
	docker build -t sum . && \
		docker run --rm sum
