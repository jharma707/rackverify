.PHONY: test
test:
	raco test -t ./rackverify-test

.PHONY: setup-lib setup-test setup-pkg
setup-lib:
	raco pkg install --skip-installed --update-deps --auto -t dir ./rackverify-lib
setup-test:
	raco pkg install --skip-installed --update-deps --auto -t dir ./rackverify-test
setup-pkg:
	raco pkg install --skip-installed --update-deps --auto -t dir ./rackverify

.PHONY: setup
setup: setup-lib setup-test setup-pkg

.PHONY: update
update: 
	racket update.rkt

