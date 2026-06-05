#lang rosette

(require (for-syntax syntax/parse)
         rosette)

(provide infer-type-from-contract
         arg+type->rosette-form)

#|
Return a type predicate syntax object
that Rosette can support.
|#
(define-syntax (infer-type-from-contract stx)
  (syntax-parse stx
    [(_ ctc)
     (syntax-parse #'ctc
       [(~or* (~literal integer?) (~literal odd?) (~literal even?))
        #'integer?]
       [(~or* ((~literal between/c) _ _) ((~literal real-in) _ _)
              ((~literal =/c) _) ((~literal </c) _) ((~literal <=/c) _)
              ((~literal >/c) _) ((~literal >=/c) _) (~literal zero?)
              (~literal positive?) (~literal negative?))
        #'real?]
       [((~literal not/c) c) #'(infer-type-from-contract c)]
       [((~literal and/c) ctcs ...)
        #'(and (infer-type-from-contract ctcs) ...)]
       [((~literal or/c) ctcs ...)
        #'(or  (infer-type-from-contract ctcs) ...)]
       [((~literal list/c) cs ...) #'(list ((infer-type-from-contract cs) ...))])]))

(define-syntax (arg+type->rosette-form stx)
  (syntax-parse stx
    [(_ arg t)
     (syntax-parse #'t
       [((~literal list) es ...)
        (with-syntax ([(pred-names ...)
                        (for/list ([e (in-list (syntax->list #'(es ...)))]
                                   [i (in-naturals 1)])
                           #'(pred-(#,i)))])
          (with-syntax ([(sym-vars ...)
                        (for/list ([e (in-list (map (λ (e) #'(infer-type-from-contract #'e)) (syntax->list #'(es ...))))]
                                   [pred-name (in-list (syntax->list #'(pred-names ...)))])
                           #'(define-symbolic pred-name e))])
            #`(define arg
                (begin
                  sym-vars ...
                  (define-symbolic size integer?)
                  (take (list pred-names ...) size)))))]
       [_ #'(define-symbolic arg t)])]))
        
  