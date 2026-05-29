#lang rosette

(require rackunit (for-syntax rackunit))

(provide verify-eq?
         verify-pred

         with-verify)

(define (verify-eq? expected result) (verify-test (assert (eq? result expected))))
(define (verify-pred pred? result) (verify-test (assert (pred? result))))

(define-syntax-rule (with-verify body ...) (verify-test body ...))

(define-syntax-rule (verify-test body ...)
   (let ([output (verify (begin body ...))])
     (if (unsat? output)
         (check-true #t)
         (with-check-info (('counterexample (model output)))
           (fail)))))
