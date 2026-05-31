#lang rosette

(require rackverify/contracts
         rosette/lib/synthax)

(module+ test
  (require rackverify)
  (define-symbolic* x y integer?))

(define/rosette-contract (f x y)
  (-> (or/c zero? positive?) positive? (not/c negative?))
  (* x y))

(module+ test
  (test-case
    "multiplication of nonnegative and positive is nonnegative"
    (verify-contract f x y)))

(define/rosette-contract (g x)
  (-> positive? negative?)
  (* x -1))

(module+ test
  (test-case
    "inverting a positive is negative"
    (verify-contract g x)))

(define/rosette-contract (h x)
  (-> integer? (between/c 1 10))
  (if (negative? x) 5 10))

(module+ test
  (test-case
    "output is within the range 1 and 10"
    (verify-contract h x)))

(define/rosette-contract (any-input x)
  (-> any/c integer?) 10)

(module+ test
  (test-case
    "can accept any input"
    (define-symbolic r real?)
    (verify-contract any-input r)))

(define/rosette-contract (any-output x)
  (-> integer? any) "hello, world")

(module+ test
  (test-case
    "can return any value"
    (define-symbolic r real?)
    (verify-contract any-output r)))

; TODO: have rackverify determine what the correct contract should be as a suggestion in the failure report
(define/rosette-contract (fill-output-contract x)
  (-> positive? positive?) -1)

(module+ test
  (test-case
    "can deduce the correct output contract"
    (define-symbolic x integer?)
    (check-exn exn:fail? (thunk (verify-contract fill-output-contract x)))))

