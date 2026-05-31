#lang rosette

(provide (all-defined-out))

(define (f x) (* x x))

(module+ test
  (require rackverify)

  (define-symbolic x integer?)

  (with-verify
    (define result (f x))
    (assert (|| (positive? result) (zero? result))))
  )
