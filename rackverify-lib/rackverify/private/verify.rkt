#lang rosette

(require rackunit
         json/format/simple
         json/format/config
         (for-syntax syntax/parse
                     rosette))

(provide (except-out (all-defined-out)
                     verify-test))

(define (verify-eq? r1 r2)
  (verify-test (assert (eq? r1 r2))))
(define (verify-equal? r1 r2)
  (verify-test (assert (equal? r1 r2))))
(define (verify-eqv? r1 r2)
  (verify-test (assert (eqv? r1 r2))))

(define (verify-pred pred? result)
  (verify-test (assert (pred? result))))

(define-syntax-rule (verify-contract f args ...)
  (verify-test (assert (f args ...))))

(define-syntax-rule (verify-test body ...)
  (let ([output (verify (begin body ...))])
    (if (unsat? output)
        (check-true #t)
        (with-check-info (('counterexample (format-jsexpr (model->jsexpr (model output)))))
          (fail "Verification failed: counterexample found")))))

(define-syntax-rule (format-jsexpr jsexpr)
  (string-info (format "\r~a" (jsexpr->pretty-json jsexpr))))

(define-syntax-rule (model->jsexpr model)
  (make-hash
   (hash-map model
             (λ (key val)
               (match key
                 [(constant id _) `(,(syntax->datum id) . ,val)])))))