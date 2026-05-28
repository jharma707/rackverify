.PHONY: test
test:
	raco test -t ./rackverify

.PHONY: setup
setup:
	raco pkg install --auto -t dir ./rackverify
