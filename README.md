# rackverify

This the source for the Racket packages: "rackverify", "rackverify-lib", and "rackverify-test."

A unit verification engine written on top of Rosette and Rackunit.

## How to run

In order to execute any of the below command, you must have `racket` and `raco` located within your
`$PATH` variable.

* `make setup`: Set up all the needed packages on a first run.
* `make update`: If you add a dependency later on and need to update the packages.
* `make test`: Execute all the example test cases.
* If you want to add additional test cases, go to the `rackverify-test/test/rackverify` directory. This will have
    example tests configured.
