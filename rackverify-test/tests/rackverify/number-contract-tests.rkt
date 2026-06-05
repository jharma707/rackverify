#lang rosette

(require rackverify/contracts
         rosette/lib/synthax)

(module+ test (require rackverify))

(define/rosette-contract/test (f x y)
  "multiplication of nonnegative and positive is nonnegative"
  (-> (or/c zero? positive?) positive? (not/c negative?))
  (* x y))

(define/rosette-contract/test (g x)
  "inverse of positive integer is a negative integer"
  (-> (and/c positive? integer?) (and/c negative? integer?))
  (* x -1))

(define/rosette-contract/test (h x)
  "output is within the range 1 and 10"
  (-> integer? (between/c 1 10))
  (if (negative? x) 5 10))

(define/rosette-contract (any-input x)
  (-> any/c integer?) 10)

(module+ test
  (test-case
    "can accept any input"
    (define-symbolic r real?)
    (verify-contract any-input r)))

(define/rosette-contract/test (any-output x)
  "can return any value"
  (-> integer? any) "hello, world")
