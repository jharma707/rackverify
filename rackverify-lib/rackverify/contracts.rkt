#lang rosette

(require (for-syntax rosette
                     syntax/parse))

(provide define/rosette-contract)

(define-syntax (define/rosette-contract stx)
  (syntax-parse stx
    [(_ (f args ...) (-> ctcs ...) body ...)
     #:fail-when (not (= (sub1 (length (syntax->list #'(ctcs ...))))
                         (length (syntax->list #'(args ...)))))
     "arity-mismatch: the number of parameters is not equal to the number of input contracts"
     (let*-values ([(input-ctcs output-ctcs) (split-at-right (syntax->list #'(ctcs ...)) 1)]
                   [(input-preds)            (map contract->predicate input-ctcs (syntax->list #'(args ...)))])
       (with-syntax ([(assumes ...) (map (lambda (pred) #`(assume #,pred)) input-preds)])
         #`(define (f args ...)
             (let ([r (begin assumes ... body ...)])
               (assert #,(contract->predicate (first output-ctcs) #'r))
               r))))]))

; (define-syntax (define/rosette-contract-with-tests stx)

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
      [((~literal real-in)   v u) (contract->predicate #'(between/c v u) symbolic-var)]))

  (define (infer-type-from-contract ctc)
    (define (number-type? t)
      (syntax-parse t
        [(~or* (~literal integer?) (~literal real?)) #t]
        [else #f]))

    (define (boolean-type? t)
      (syntax-parse t
        [(~literal boolean?) #t]
        [else #f]))

    (define (all-same-type? ctcs)
     (cond [(number-type?  (first ctcs)) (andmap number-type?  (rest ctcs))]
           [(boolean-type? (first ctcs)) (andmap boolean-type? (rest ctcs))]))

    (define (get-type-priority t)
      (syntax-parse t
        ; number type priorities
        [(~literal integer?) 0]
        [(~literal real?)    1]
        ; boolean type priorities
        [(~literal boolean?) 0]))
    
    (syntax-parse ctc
      [(~or* (~literal integer?) (~literal odd?) (~literal even?))
       #'integer?]
      [(~or* ((~literal between/c) _ _) ((~literal real-in) _ _)
             ((~literal =/c) _) ((~literal </c) _) ((~literal <=/c) _)
             ((~literal >/c) _) ((~literal >=/c) _) (~literal zero?))
       #'real?]
      [((~literal not/c) c) (infer-type-from-contract #'c)]
      [((~literal and/c) ctcs ...)
       #:with      inferred-types (map infer-type-from-contract (syntax->list #'(ctcs ...)))
       #:fail-when (not (all-same-type? #'inferred-types))
       (format "type-mismatch: the contract's type is not consistent\n~a" `(and/c ,(syntax->datum #'(ctcs ...))))
       #'(#,(argmin (map (lambda (t) (cons (get-type-priority t) t))
                         inferred-types)))]
      [((~literal or/c) ctcs ...)
       #:with      inferred-types (map infer-type-from-contract (syntax->list #'(ctcs ...)))
       #:fail-when (not (all-same-type? #'inferred-types))
       (format "type-mismatch: the contract's type is not consistent\n~a" `(or/c ,(syntax->datum #'(ctcs ...))))
       #'(#,(argmax (map (lambda (t) (cons (get-type-priority t) t))
                         inferred-types)))]
      ))
  )
