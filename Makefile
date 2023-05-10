.PHONY: all
all: css js images

.PHONY: clean
clean:
	rm -rf public/assets/*

.PHONY: images
images:
	mkdir -p public/assets/images
	tar -C lib/assets/images -cf - . | tar -C public/assets/images -xf -

.PHONY: js
js:
	mkdir -p public/assets/javascripts
	cat gems/jquery-rails/vendor/assets/javascripts/jquery.js \
	  gems/jquery-rails/vendor/assets/javascripts/jquery_ujs.js \
	  lib/assets/javascripts/mgetit.js \
	  > public/assets/javascripts/mgetit.js

.PHONY: css
css:
	mkdir -p public/assets/stylesheets
	bundle exec scss lib/assets/stylesheets/umlaut.css.scss public/assets/stylesheets/mgetit.css
