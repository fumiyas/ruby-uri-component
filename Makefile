RAKE=		rake
GEM=		gem

test t: PHONY
	$(RAKE) test

gem: PHONY
	$(RAKE) build

upload: PHONY
	$(RM) pkg/*.gem
	$(MAKE) gem
	$(GEM) push pkg/*.gem

install: PHONY
	$(RAKE) install

PHONY:

