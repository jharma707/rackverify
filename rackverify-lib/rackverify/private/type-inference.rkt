#lang rosette

(require (for-syntax syntax/parse racket/syntax)
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
       [((~literal list/c) cs ...) #'(list (infer-type-from-contract cs) ...)])]))

(define-syntax (arg+type->rosette-form stx)
  (syntax-parse stx
    [(_ arg t)
     (syntax-parse #'t
       [((~literal list) ts ...)
        (with-syntax* ([(pred-names ...)
                        (for/list ([e (in-list (syntax->list #'(ts ...)))]
                                   [i (in-naturals 1)])
                           (format-id #'arg "~a-~a" #'arg i))]
                       [(sym-vars ...)
                        (for/list ([e    (in-list (syntax->list #'(ts ...)))]
                                   [name (in-list (syntax->list #'(pred-names ...)))])
                           #`(define-symbolic #,name #,e))])
            #`(begin
                sym-vars ...
                (define arg (list pred-names ...))))]
       [_ #'(define-symbolic arg t)])]))
        
  