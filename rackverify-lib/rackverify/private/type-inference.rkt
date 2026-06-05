#lang rosette

(require (for-syntax syntax/parse racket/syntax)
         rosette)

(provide infer-type-from-contract
         arg+type->rosette-form)

(begin-for-syntax
  (define max-list-bound 5))

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
       [(~literal boolean?) #'boolean?]
       
       [((~literal not/c) c)  #'(infer-type-from-contract c)]
       [((~literal listof) c) #'(list* (infer-type-from-contract c))]
               
       [((~literal and/c) ctcs ...)
        #'(and   (infer-type-from-contract ctcs) ...)]
       [((~literal or/c) ctcs ...)
        #'(or    (infer-type-from-contract ctcs) ...)]
       [((~literal list/c) ctcs ...)
        #'(list  (infer-type-from-contract ctcs) ...)])]))

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
       [((~literal list*) ctc)
        (with-syntax* ([(pred-names ...)
                        (for/list ([i (in-inclusive-range 1 max-list-bound)])
                           (format-id #'arg "~a-~a" #'arg i))]
                       [(sym-vars ...)
                        (for/list ([name (in-list (syntax->list #'(pred-names ...)))])
                           #`(define-symbolic #,name ctc))]
                       [arg-size (format-id #'arg "~a-sz" #'arg)])
            #`(begin
                sym-vars ...
                (define-symbolic arg-size integer?)
                (define arg (take (list pred-names ...) arg-size))))]
       [_ #'(define-symbolic arg t)])]))
        
  