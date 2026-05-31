#lang rosette

(require rackunit)

(provide verify-eq?
         verify-equal?
         verify-eqv?
         verify-pred
         verify-contract
         pass

         test-begin
         test-case)

; TODO: add an inductive spec (see queue example for forAll cases)

(define (verify-eq? r1 r2)
  (verify-test (assert (eq? r1 r2))))
(define (verify-equal? r1 r2)
  (verify-test (assert (equal? r1 r2))))
(define (verify-eqv? r1 r2)
  (verify-test (assert (eqv? r1 r2))))

(define (pass) (check-true #t))

(define (verify-pred pred? result)
  (verify-test (assert (pred? result))))

(define (verify-contract f args ...)
  (verify-test (apply f (list args ...))))

(define-syntax-rule (verify-test body ...)
   (let ([output (verify (begin body ...))])
     (if (unsat? output)
         (pass)
         (with-check-info (('counterexample (model output)))
           (fail)))))
