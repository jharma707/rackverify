#lang rosette

(require rackverify/contracts)

(module+ test
  (require rackverify)
  (define-symbolic* x y integer?))

(define/rosette-contract (f x)
  (-> integer? positive?) ; change to (or/c positive? negative?)
  (* (add1 (abs x)) 10))

(module+ test (verify-contract f x))

(define/rosette-contract (g y)
  (-> positive? negative?)
  (* y -1))

(module+ test (verify-contract g y))
