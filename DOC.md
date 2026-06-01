## What are you solving? What are the inputs? What are the outputs? Why is a solver the right tool?

For my project, I am developing a unit verification engine primarily designed for determining
if a function satisfies all of its contracts (runtime predicates on input and output). This is
a generic utility, so there are no specific inputs and outputs; it's designed to accept any
function. The solver helps enormously with this since it can provide a proof that the predicate
on the output is always satisfied, allowing for the output contract to be stripped away at compile-time.
Even though this could be done by annotating the code with assumes and asserts, the syntactic
convenience of using contracts enables a cleaner implementation.

## Point at the file in your code that runs the end-to-end example.

All the example tests are under `rackverify-test/tests/rackverify/contract-tests.rkt`. It tests
functions with various inputs and contracts. The `define/rosette-contract` macro is what does
the work of expanding the implementation and inserting the proper assumes and asserts throughout
the implementation.

## What will you add between now and the final? What will your "beats naive" story be?

For the most part, my current implementation converts the contracts into Rosette formulas quite well.
Between now and the final, I wish to expand the feature set of the library some more. In particular, I plan
to have the testing engine provide a syntactic form that automatically inserts the contract tests. Furthermore,
I want the test engine to automatically suggest a correct output predicate if the verification test were to fail.
For example, if the user listed `positive?` as the output contract - and the actual predicate should be
`(not/c negative?)` - then I want the failure report to include that information. This will require using
Rosette's synthesis feature to choose from a select number of options. At first, it will probably only
support a single type predicate; as a stretch goal, I want it to support an arbitrarily nested predicate
to some bound (since choose requires a finite list of choices).
