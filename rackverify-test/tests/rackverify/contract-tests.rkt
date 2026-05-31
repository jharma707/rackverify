#lang rosette

(require rackverify/contracts)

(module+ test (require rackverify))

(define/rosette-contract (f x y)
  (-> (or/c zero? positive?) positive? (not/c negative?))
  (* x y))

(module+ test
  (test-begin
    (define-symbolic* x y integer?)
    (verify-contract f x y)))

(define/rosette-contract (g x)
  (-> positive? negative?)
  (* x -1))

(module+ test
  (test-begin
    (define-symbolic x integer?)
    (verify-contract g x)))

(define/rosette-contract (h x)
  (-> integer? (between/c 1 10))
  (if (negative? x) 5 10))

(module+ test
  (test-begin
    (define-symbolic x integer?)
    (verify-contract h x)))

(define/rosette-contract (any-input x)
  (-> any/c integer?) 10)

(module+ test
  (test-begin
    (define-symbolic x real?)
    (verify-contract any-input x)))
