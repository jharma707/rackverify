#lang rosette

(require syntax/parse
         (for-syntax rosette syntax/parse))

(provide define/rosette-contract)

(define-syntax (define/rosette-contract stx)
  (syntax-case stx ()
    [(_ (f args ...) (-> ctcs ...) body ...)
     (let*-values ([(input-ctcs output-ctcs) (split-at-right (syntax->list #'(ctcs ...)) 1)]
                   [(args)                   (syntax->list #'(args ...))]
                   [(input-preds)            (map contract->predicate input-ctcs args)])
       (with-syntax ([(args ...)    args]
                     [(assumes ...) (map (lambda (pred) #`(assume #,pred)) input-preds)])
         #`(define (f args ...)
             (let ([r (begin assumes ... body ...)])
               (assert #,(contract->predicate (first output-ctcs) #'r))
               r))))]))

(begin-for-syntax
  (define (contract->predicate ctc symbolic-var)
    (define (map-contracts ctcs)
      (map (lambda (ctc) (contract->predicate ctc symbolic-var)) (syntax->list ctcs)))

    (syntax-parse ctc
      [(~literal integer?)  #`(integer?  #,symbolic-var)]
      [(~literal positive?) #`(positive? #,symbolic-var)]
      [(~literal negative?) #`(negative? #,symbolic-var)]
      [(~literal zero?)     #`(zero?     #,symbolic-var)]
      [((~literal not/c) ctc) #`(! #,(contract->predicate #'ctc symbolic-var))]
      [((~literal or/c) ctcs ...)
       #:with (predicates ...) (map-contracts #'(ctcs ...))
       #`(|| predicates ...)]
      [((~literal and/c) ctcs ...)
       #:with (predicates ...) (map-contracts #'(ctcs ...))
       #`(&& predicates ...)]))
  )
