(+ 19 99)
(+ 2 98)
(+  98 2 )
(+  38 2 )
(+ -19 -99)

(- 3 -17)
(- -3 29)

(- 10 10)
(- -999 -999)

(- 3 2)

(- 1 3)

(- 111 3)

(- 100 3)

(- 3 994)

(+ 2 -3)

(+ -2 3)
(+ -9 2)
(+ -2 9)


(- -1 -3)
(- -5 -3)

(- 0 0)
(- 0 0)

(- 11 2)

(- 8 9)

;(- 9 9)
;(- 9 0)
;(- 34 1)

;(- 34 7)

;(if 1 2 3)
1
(+ 1(+ 1 1))

(+(- 9 2) 1)

(- (- 9 2) (- 3 7))

(+ (+ (+ 1 2) 3) 4)
(+ 1 (+ 2 (+ 3 4)))

(eq 3 4)
(eq 12 12)

(if (eq 2 (+ 1 1)) (+ 3 4) (+ 4 2))

(if (eq 2 (+ 3 1)) (+ 3 4) (+ 2 4))

(if t 2 3)
(if nil 2 3)

(if (eq 4 2) 2 (+ (+ 4 1) 3))

(+ (if (eq 2 (+ 3 1)) (+ 3 4) (+ 2 4)) 4)
(+ 4 (if (eq 2 (+ 3 1)) (+ 3 4) (+ 2 4)))

(+ 3 (if (eq 4 4) (+ 2 (+ 3 2)) (+ 4 3)))
(+ 3 (if (eq 4 2) (+ 2 (+ 3 2)) (+ (+ 4 1) 3)))

(+ 3 (if t 2 3))
(+ 3 (if nil 2 3))

(- 3 (+ 3 (if (eq 4 2) (+ 2 (+ 3 2)) (- (+ 4 1) (+ 3 9)))))
(if (eq (+ 1 2) (- 3 1)) (- (+ 2 3) (+ 3 9)) (+ (+ 2 3) (+ 3 9)))
(if (eq (+ 1 2) (- 4 1)) (- (+ 2 3) (+ 3 9)) (+ (+ 2 3) (+ 3 9)))

(defun f () 42) ;cont
(f)
(defun f () (+ 4 8)) ;cont
(f)
(defun f (n) (+ n n)) ;cont
(f 42)

(* 23 33)

(/ 45 7)
(mod 45 7)

(quote ((1 2) (3 4)))
(quote (()))

()
(car ())
(car nil)
(car (quote ()))
(car (quote (3)))
(car (quote (42 99)))
(car (quote ((42 99) (3 7))))
(car (quote ((42 (11 22) 99) (3 7))))

(cdr ())
(cdr nil)
(cdr (quote ()))
(cdr (quote (3)))
(cdr (quote (42 99)))
(cdr (quote ((42 99) (3 7))))
(cdr (quote ((42 (11 22) 99) (3 7))))

(cons 42 nil)
(cons 42 ())
(cons nil nil)
(cons 42 (quote ()))
(cons 1 (quote (2)))
(cons (quote (1 2)) (quote (3 ((5 6)) 4)))

(atom ())
(atom nil)
(atom t)
(atom 42)
(atom (quote ()))
(atom (quote (3)))
(atom (quote (42 99)))
(atom (quote ((42 99) (3 7))))
(atom (quote ((42 (11 22) 99) (3 7))))

; TEST LAMBDA

((lambda (n) (+ 4 n)) 42)
((lambda (n m) (- m n)) 42 99)
((lambda (x) x) 42)

(define foo 42) ;cont
foo

(define func (lambda (x y z) y)) ;cont
(func 1 2 3)

((lambda (f) (f)) (lambda () 42))

(defun func (a b) b) ;cont
(defun func2 (a b) (+ (func 2 3) b)) ;cont
(func2 99 42)

; TEST EVAL

(defmacro let (l e) (cons (cons lambda (cons (cons (car l) nil) (cons e nil))) (cons (car (cdr l)) nil))) ;cont
(let (x 42) (+ x 7))

(defun list0 (a) (cons a nil)) ;cont
(defun cadr (a) (car (cdr a))) ;cont
(defmacro cond (l) (if l (cons if (cons (car (car l)) (cons (cadr (car l)) (cons (cons (quote cond) (list0 (cdr l))))))) nil)) ;cont
(defun fb (n) (cond (((eq (mod n 5) 0) Buzz) ((eq (mod n 3) 0) Fizz) (t n)))) ;cont
(fb 18)
