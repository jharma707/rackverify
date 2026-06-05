#lang rosette

(require rackverify/contracts)

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
  (-> (list/c positive? zero?) (list/c positive? zero?))
  (reverse (reverse ls)))

(define/rosette-contract/test (bounded ls)
  "length of bounded list is non-negative"
  (-> (listof integer?) (not/c negative?))
  (length ls))

(define/rosette-contract/test (list-type xs)
  "list contents are verified"
  (-> (listof integer?) (listof integer?))
  (reverse xs))

(define/rosette-contract/test (append-type xs ys)
  "list append maintains the list types"
  (-> (listof integer?) (listof integer?) (listof integer?))
  (append xs ys))

(define/rosette-contract/test (involution2 ls)
  "bounded list reverse is an inverse of itself"
  (-> (listof integer?) (listof integer?))
  (let ([r (reverse (reverse ls))])
    (assert (equal? r ls))
    r))

