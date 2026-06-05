#lang rosette

(require "main.rkt"
         "private/type-inference.rkt"
         (for-syntax rosette
                     syntax/parse
                     "private/type-inference.rkt"
                     "main.rkt"))

(provide define/rosette-contract
         define/rosette-contract/test)

(define-syntax (define/rosette-contract stx)
  (syntax-parse stx
    [(_ (f args ...) (-> ctcs ...) body ...)
     #:fail-when (not (= (sub1 (length (syntax->list #'(ctcs ...))))
                         (length (syntax->list #'(args ...)))))
     "arity-mismatch: the number of parameters is not equal to the number of input contracts"
     (let*-values ([(input-ctcs output-ctcs) (split-at-right (syntax->list #'(ctcs ...)) 1)]
                   [(input-preds)            (map contract->predicate input-ctcs (syntax->list #'(args ...)))])
       (with-syntax ([(assumes ...) (map (λ (pred) #`(assume #,pred)) input-preds)])
         #`(define (f args ...)
             (let ([r (begin assumes ... body ...)])
               (assert #,(contract->predicate (first output-ctcs) #'r))
               r))))]))

(define-syntax (define/rosette-contract/test stx)
  (syntax-parse stx
    [(_ (f args ...) message (-> ctcs ...) body ...)
     (with-syntax ([(sym-vars ...)
                    (for/list ([arg (syntax->list #'(args ...))]
                               [ctc (syntax->list #'(ctcs ...))])
                      (define type (local-expand #`(infer-type-from-contract #,ctc) 'expression (list #'#%app)))
                      #`(arg+type->rosette-form #,arg #,type))])
       #'(begin
           (define/rosette-contract (f args ...) (-> ctcs ...) body ...)
           (module+ test
             (test-case message
               sym-vars ...
               (verify-contract f args ...)))))]))

(begin-for-syntax
  (define (contract->predicate ctc symbolic-var)
    (syntax-parse ctc
      [(~or* (~literal integer?) (~literal real?)
             (~literal positive?) (~literal negative?)
             (~literal zero?)
             (~literal even?) (~literal odd?))
       #`(#,ctc #,symbolic-var)]

      [(~literal any)    #'#t]
      [(~literal any/c)  #'#t]
      [(~literal none/c) #'#f]

      [((~literal or/c) ctcs ...)
       #:with (predicates ...) (map (λ (c) (contract->predicate c symbolic-var)) (syntax->list #'(ctcs ...)))
       #`(|| predicates ...)]
      [((~literal and/c) ctcs ...)
       #:with (predicates ...) (map (λ (c) (contract->predicate c symbolic-var)) (syntax->list #'(ctcs ...)))
       #`(&& predicates ...)]

      [((~literal =/c)  v) #`(eq? #,symbolic-var v)]
      [((~literal </c)  v) #`(<   #,symbolic-var v)]
      [((~literal <=/c) v) #`(<=  #,symbolic-var v)]
      [((~literal >/c)  v) #`(>   #,symbolic-var v)]
      [((~literal >=/c) v) #`(>=  #,symbolic-var v)]

      [((~literal not/c)     ctc) #`(! #,(contract->predicate #'ctc symbolic-var))]
      [((~literal between/c) v u) #`(&& (>= #,symbolic-var v) (<= #,symbolic-var u))]
      [((~literal real-in)   v u) (contract->predicate #'(between/c v u) symbolic-var)]

      [((~literal list/c) ctcs ...)
       #:with (accessors ...) (for/list ([ctc (syntax->list #'(ctcs ...))]
                                         [pos (in-naturals 0)])
                                (contract->predicate ctc #`(list-ref #,symbolic-var #,pos)))
       #`(&& (list? #,symbolic-var) accessors ...)]))
  )
