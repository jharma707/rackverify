#lang rosette

(require rackverify/contracts
         rosette/lib/synthax)

(module+ test (require rackverify))

(define/rosette-contract/test (test-len ls)
  "can validate list length"
  (-> (list/c integer? integer?) (=/c 2))
  (length ls))

(define/rosette-contract/test (multiply-es ls)
  "positive element and a negative element make a negative result"
  (-> (list/c positive? negative?) negative?)
  (* (car ls)
     (cadr ls)))

(define/rosette-contract/test (involution ls)
  "list reverse is an inverse of itself"
  (-> (list/c positive? negative?) (list/c positive? negative?))
  (reverse (reverse ls)))

