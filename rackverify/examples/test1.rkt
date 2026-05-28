#lang rosette

(provide (all-defined-out))

(define (f x) (* x 10))

(module+ test
  (require rackunit)

  (define-symbolic x integer?)
  (define result (verify (assert (positive? (f x)))))

  (if (unsat? result)
      (check-true #t)
      (fail (format "~a" (model result))))
  )
