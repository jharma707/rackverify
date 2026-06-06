#lang racket/base

(require racket/syntax)

(provide list-constants)

(define max-list-bound 5)

(define (list-constants arg)
  (for/list ([i (in-inclusive-range 1 max-list-bound)])
    (format-id arg "~a-~a" arg i)))