#lang rosette

(provide (all-defined-out))

(define (f x) (* x x))

(module+ test
  (require rackverify)

  (define-symbolic x integer?)

  (test-begin
    (define result (f x))
    (assert (|| (positive? result) (zero? result))))
  )
