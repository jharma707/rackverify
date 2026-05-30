#lang rosette

(require rackunit)

(provide verify-eq?
         verify-equal?
         verify-eqv?
         verify-pred
         verify-contract

         with-verify)

(define (verify-eq? r1 r2 #:message message)
  (verify-test (assert (eq? r1 r2))))
(define (verify-equal? r1 r2 #:message message)
  (verify-test (assert (equal? r1 r2))))
(define (verify-eqv? r1 r2 #:message message)
  (verify-test (assert (eqv? r1 r2))))

(define (verify-pred pred? result #:message message)
  (verify-test (assert (pred? result))))

(define-syntax-rule (with-verify body ...)
  (verify-test body ...))

(define-syntax-rule (verify-contract f args ...)
  (verify-test (assert (apply f (list args ...)))))

(define-syntax-rule (verify-test body ...)
   (let ([output (verify (begin body ...))])
     (if (unsat? output)
         (check-true #t)
         (with-check-info (('counterexample (model output)))
           (fail "something failed")))))
