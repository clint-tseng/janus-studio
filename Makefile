default: build

SRC = $(shell find src -name "*.coffee" -type f | sort)
LIB = $(SRC:src/%.coffee=lib/%.js)
ASSETS_SRC = $(shell find src/assets -type f | sort)
ASSETS_LIB = $(ASSETS_SRC:src/assets/%=lib/assets/%)

lib:
	mkdir lib/

lib/%.js: src/%.coffee lib node_modules
	node node_modules/coffee-script/bin/coffee --output "$(@D)" --compile "$<"

lib/app.html: src/app.html lib
	cp src/app.html lib/

lib/app.css: src/app.sass src/styles/*.sass lib
	node node_modules/node-sass/bin/node-sass --output-style compressed $< > $@

lib/assets: lib
	mkdir lib/assets

lib/assets/%: src/assets/% lib/assets
	cp $< $@

node_modules:
	npm install

build: $(LIB) lib/app.html lib/app.css $(ASSETS_LIB)

test: build node_modules
	node node_modules/mocha/bin/mocha --compilers coffee:coffee-script/register --recursive

clean:
	rm -rf lib

