NODE_BIN ?= $(shell asdf which node || nvm which node || command -v node)
UNAME_S := $(shell uname -s)
JS_FILES := $(shell git ls-files '*.js')

# build the `sum` binary
#
# https://nodejs.org/api/single-executable-applications.html
#
# $@ means "the name of this target"
dist/sum: dist/bundle.js
	node --experimental-sea-config sea-config.json
	cp $(NODE_BIN) $@
ifeq ($(UNAME_S),Darwin)
	codesign --remove-signature $@
	npx postject $@ NODE_SEA_BLOB dist/sea-prep.blob \
		--sentinel-fuse NODE_SEA_FUSE_fce680ab2cc467b6e072b8b5df1996b2 \
		--macho-segment-name NODE_SEA 
	codesign --sign - $@
else
	npx postject dist/rb NODE_SEA_BLOB dist/sea-prep.blob \
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

.PHONY: clean
clean:
	rm dist/*
