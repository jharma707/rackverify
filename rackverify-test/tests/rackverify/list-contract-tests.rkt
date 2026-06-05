#lang rosette

(require rackverify/contracts
         rosette/lib/synthax)

(module+ test (require rackverify))

(define/rosette-contract/test (test-len ls)
  "can validate list length"
  (-> (list/c integer? integer?) (=/c 2))
  (length ls))