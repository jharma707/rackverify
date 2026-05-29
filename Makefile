.PHONY: test
test:
	raco test -t ./rackverify-test

.PHONY: setup
setup:
	raco pkg install --auto -t dir ./rackverify
