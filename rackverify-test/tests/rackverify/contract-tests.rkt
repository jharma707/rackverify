#lang rosette

(require rackverify/contracts)

(module+ test
  (require rackverify)
  (define-symbolic* x y integer?))

(define/rosette-contract (f x y)
  (-> (or/c zero? positive?) positive? (not/c negative?))
  (* x y))

(module+ test (verify-contract f x y))

(define/rosette-contract (g y)
  (-> positive? negative?)
  (* y -1))

(module+ test (verify-contract g y))
