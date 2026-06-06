#lang racket/base

(require pkg/lib)

(define (installed? pkg-name)
  (with-pkg-lock/read-only
    (hash-ref (installed-pkg-table) pkg-name #f)))

(define pkg "rackverify")

(if (installed? pkg)
  (with-pkg-lock
    (pkg-update 
      (list (pkg-desc (format "./~a" pkg) 'dir #f #f #t))
      #:dep-behavior 'search-auto
      #:update-deps? #t))
  (raise (format "~a is not installed. Try running 'make setup'." pkg)))
