#lang rosette

(require (for-syntax rosette))

(provide define/rosette-contract)

(define-syntax (define/rosette-contract stx)
  (syntax-case stx ()
    ; check that the input predicates and the arguments match (raise-syntax-error)
    [(_ (f args ...) (-> preds ...) body ...)
     (let ([input-preds (drop-right (syntax->list #'(preds ...)) 1)]
           [output-pred (last (syntax->list #'(preds ...)))]
           [args        (syntax->list #'(args ...))])
       (with-syntax ([(input-preds ...) input-preds]
                     [(args ...)        args]
                     [(assumes ...)     (map (lambda (pred arg) #`(assume (#,pred #,arg)))
                                             input-preds args)])
         #`(define/contract (f args ...)
             (-> input-preds ... any)
             (let ([r (begin assumes ... body ...)])
               (assert (#,output-pred r))
               r))))]))
