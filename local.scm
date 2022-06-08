(define first
  (lambda (p)
    (car p)))

(define second
  (lambda (p)
    (car (cdr p))))

(define third
  (lambda (l)
    (car (cdr (cdr l)))))

; An entry is a pair of lists whose first list is a set. The two lists must be of equal length.

(define lookup-in-entry
  (lambda (name entry entry-f)
    (lookup-in-entry-help
      name
      (first entry)
      (second entry)
      entry-f)))

(define lookup-in-entry-help
  (lambda (name names values entry-f)
    (cond
      ((null? names) (entry-f name))
      ((eq? (car names) name) (car values))
      (else
        (lookup-in-entry-help
          name
          (cdr names)
          (cdr values)
          entry-f)))))

(lookup-in-entry
  'entree
  '((appetizer entree bevarage) (pate boeuf vin))
  (lambda (n) '()))

(lookup-in-entry
  'no-such-item
  '((appetizer entree bevarage) (pate boeuf vin))
  (lambda (n) '()))

; A table (also called an environment) is a list of entries.

(define lookup-in-table
  (lambda (name table table-f)
    (cond
      ((null? table) (table-f name))
      (else
        (lookup-in-entry
          name
          (car table)
          (lambda (name)
            (lookup-in-table
              name
              (cdr table)
              table-f)))))))

(lookup-in-table
  'dessert
  '(((entree dessert) (spaghetti spumoni))
    ((appetizer entree beverage) (food tastes good)))
  (lambda (n) '()))

(lookup-in-table
  'no-such-item
  '(((entree dessert) (spaghetti spumoni))
    ((appetizer entree beverage) (food tastes good)))
  (lambda (n) '()))


; Let's build our interpreter!

(define atom?
 (lambda (x)
    (and (not (pair? x)) (not (null? x)))))

(define expression-to-action
  (lambda (e)
    (cond
      ((atom? e) (atom-to-action e))
      (else
        (list-to-action e)))))

(define atom-to-action
  (lambda (e)
    (cond
      ((number? e) *const)
      ((eq? e #t) *const)
      ((eq? e #f) *const)
      ((eq? e 'cons) *const)
      ((eq? e 'car) *const)
      ((eq? e 'cdr) *const)
      ((eq? e 'null?) *const)
      ((eq? e 'eq?) *const)
      ((eq? e 'atom?) *const)
      ((eq? e 'zero?) *const)
      ((eq? e 'add1) *const)
      ((eq? e 'sub1) *const)
      ((eq? e 'number?) *const)
      (else *identifier))))

(define list-to-action
  (lambda (e)
    (cond
      ((atom? (car e))
       (cond
         ((eq? (car e) 'quote) *quote)
         ((eq? (car e) 'lambda) *lambda)
         ((eq? (car e) 'cond) *cond)
         (else *application)))
      (else *application))))

(define value
  (lambda (e)
    (meaning e '())))

(define meaning
  (lambda (e table)
    ((expression-to-action e) e table)))

(define *const
  (lambda (e table)
    (cond
      ((number? e) e)
      ((eq? e #t) #t)
      ((eq? e #f) #f)
      (else
        (list 'primitive e)))))

; Example 1
(value 'car)

;(meaning car '())
;((expression-to-action car) car '())
;(atom-to-action car)
;(*const car '())
;(list 'primitive car)

(define *quote
  (lambda (e table)
    (text-of e)))

(define text-of second)

; Example 2
(value '(quote nothing))

;(meaning (quote nothing) '())
;((expression-to-action (quote nothing)) (quote nothing) '())
;(list-to-action (quote nothing))
;(*quote (quote nothing) '())
;(second (quote nothing))

(define *identifier
  (lambda (e table)
    (lookup-in-table e table initial-table)))

(define initial-table
  (lambda (name)
    (car '()))) ; let's hope we don't take this path

; Example 3
(meaning 'help '(((help) (1))))

;((expression-to-action help) help '(((help) (1))))
;(atom-to-action help)
;(*identifier help '(((help) (1))))
;(lookup-in-table help '(((help) (1))) initial-table)


(define *lambda
  (lambda (e table)
    (list 'non-primitive
          (cons table (cdr e)))))

; Example 4
(meaning '(lambda (x) (cons x y)) '(((y z) ((8) 9))))

;((expression-to-action (lambda (x) (cons x y))) (lambda (x) (cons x y)) (lambda (x) (cons x y)))
;(list-to-action (lambda (x) (cons x y)))
;(*lambda (lambda (x) (cons x y)) (((y z) ((8) 9))))
;(list 'non-primitive (cons (((y z) ((8) 9))) (cdr (lambda (x) (cons x y)))))


(define question-of first)
(define answer-of second)

(define evcon
  (lambda (lines table)
    (cond
      ((else? (question-of (car lines)))
       (meaning (answer-of (car lines)) table))
      ((meaning (question-of (car lines)) table)
       (meaning (answer-of (car lines)) table))
      (else
        (evcon (cdr lines) table)))))

(define else?
  (lambda (x)
    (cond
      ((atom? x) (eq? x 'else))
      (else #f))))

(define *cond
  (lambda (e table)
    (evcon (cond-lines-of e) table)))

(define cond-lines-of cdr)

; Example 5
(*cond '(cond (coffee klatsch) (else party)) '(((coffee) (#f)) ((klatsch party) (5 (6)))))

;(evcon ((coffee klatsch) (else party)) (((coffee) (#f)) ((klatsch party) (5 (6)))))
;(else? coffee)
;(meaning coffee (((coffee) (#f)) ((klatsch party) (5 (6)))))
;(evcon ((else party)) (((coffee) (#f)) ((klatsch party) (5 (6)))))
;(else? else)
;(meaning party (((coffee) (#f)) ((klatsch party) (5 (6)))))


(define evlis
  (lambda (args table)
    (cond
      ((null? args) '())
      (else
        (cons (meaning (car args) table)
              (evlis (cdr args) table))))))

(define *application
  (lambda (e table)
    (applyz
      (meaning (function-of e) table)
      (evlis (arguments-of e) table))))

(define function-of car)
(define arguments-of cdr)

(define primitive?
  (lambda (l)
    (eq? (first l) 'primitive)))

(define non-primitive?
  (lambda (l)
    (eq? (first l) 'non-primitive)))

(define applyz
  (lambda (fun vals)
    (cond
      ((primitive? fun)
       (apply-primitive (second fun) vals))
      ((non-primitive? fun)
       (apply-closure (second fun) vals)))))

(define apply-primitive
  (lambda (name vals)
    (cond
      ((eq? name 'cons)
       (cons (first vals) (second vals)))
      ((eq? name 'car)
       (car (first vals)))
      ((eq? name 'cdr)
       (cdr (first vals)))
      ((eq? name 'null?)
       (null? (first vals)))
      ((eq? name 'eq?)
       (eq? (first vals) (second vals)))
      ((eq? name 'atom?)
       (:atom? (first vals)))
      ((eq? name 'zero?)
       (zero? (first vals)))
      ((eq? name 'add1)
       (+ 1 (first vals)))
      ((eq? name 'sub1)
       (- 1 (first vals)))
      ((eq? name 'number?)
       (number? (first vals))))))

(define :atom?
  (lambda (x)
    (cond
      ((atom? x) #t)
      ((null? x) #f)
      ((eq? (car x) 'primitive) #t)
      ((eq? (car x) 'non-primitive) #t)
      (else #f))))

(define table-of first)
(define formals-of second)
(define body-of third)
(define extend-table cons)
(define new-entry list)

(define apply-closure
  (lambda (closure vals)
    (meaning
      (body-of closure)
      (extend-table (new-entry
                      (formals-of closure)
                      vals)
                    (table-of closure)))))

; Example 6
(*application '((lambda (x y) (eq? x y)) 1 2) '())

;(applyz (meaning '(lambda (x y) (eq? x y)) '()) (evlis '(1 2) '()))
;(applyz '(non-primitive (() (x y) (eq? x y))) '(1 2))
;(apply-closure '(() (x y) (eq? x y)) '(1 2))
;(meaning '(eq? x y) (cons (list '(x y) '(1 2)) '()))



; Comprehensive examples
(value '(add1 6))
(value '(quote (a b c)))
(value '(car (quote (a b c))))
(value '(cdr (quote (a b c))))
(value
  '((lambda (x)
      (cons x (quote ())))
    (quote (foo bar baz))))
(value
  '((lambda (x)
      (cond
        (x (quote true))
        (else
          (quote false))))
    #t))