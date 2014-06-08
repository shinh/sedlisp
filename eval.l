(defun cadr (s) (car (cdr s)))
(defun cddr (s) (cdr (cdr s)))

;(defun table-add (m k v) (if m (if (eq (car m) k) (cons k (cons v (cddr m))) (cons (car m) (cons (cadr m) (table-add (cddr m) k v)))) (cons k (cons v nil))))
(defun table-add (m k v) (cons k (cons v m)))

(define gval-table ())
(defun gval-table-add (k v) (define gval-table (table-add gval-table k v)))

(define val-table ())

(defun eval (s) (if (atom s) (eval-val s) (eval-if (car s) (cdr s))))

(defun eval-gval-1 (v s) (if v (if (eq (car v) s) (cadr v) (eval-gval-1 (cddr v) s)) s))
(defun eval-gval (s) (eval-gval-1 gval-table s))

(defun eval-val-1 (v s) (if v (if (eq (car v) s) (cadr v) (eval-val-1 (cddr v) s)) (eval-gval s)))
(defun eval-val (s) (eval-val-1 val-table s))

(defun eval-if (o s) (if (eq o if) (run-if s) (eval-defmacro o s)))
(defun eval-defmacro (o s) (if (eq o defmacro) (run-defmacro s) (eval-defun o s)))
(defun eval-defun (o s) (if (eq o defun) (run-defun s) (eval-lambda o s)))
(defun eval-lambda (o s) (if (eq o lambda) (run-lambda s) (eval-quote o s)))
(defun eval-quote (o s) (if (eq o quote) (run-quote s) (eval-define o s)))
(defun eval-define (o s) (if (eq o define) (run-define s) (eval-macro (eval o) s)))
(defun is-macro (o) (if (atom o) nil (eq (car o) macro)))
(defun eval-macro (o s) (if (is-macro o) (run-macro (cdr o) s) (eval-func o s)))
(defun is-func (o) (if (atom o) nil (eq (car o) lambda)))
(defun eval-func (o s) (if (is-func o) (run-func (cdr o) s) (eval-add o s)))
(defun eval-add (o s) (if (eq o +) (run-add s) (eval-sub o s)))
(defun eval-sub (o s) (if (eq o -) (run-sub s) (eval-mul o s)))
(defun eval-mul (o s) (if (eq o *) (run-mul s) (eval-div o s)))
(defun eval-div (o s) (if (eq o /) (run-div s) (eval-mod o s)))
(defun eval-mod (o s) (if (eq o mod) (run-mod s) (eval-eq o s)))
(defun eval-eq (o s) (if (eq o eq) (run-eq s) (eval-car o s)))
(defun eval-car (o s) (if (eq o car) (run-car s) (eval-cdr o s)))
(defun eval-cdr (o s) (if (eq o cdr) (run-cdr s) (eval-cons o s)))
(defun eval-cons (o s) (if (eq o cons) (run-cons s) (eval-atom o s)))
(defun eval-atom (o s) (if (eq o atom) (run-atom s) (eval-neg o s)))
(defun eval-neg (o s) (if (eq o neg?) (run-neg s) (eval-print o s)))
(defun eval-print (o s) (if (eq o print) (run-print s) (undefined-func o)))
(defun undefined-func (o) (print (cons o (quote (undefined func)))))

(defun run-if (s) (if (eval (car s)) (eval (cadr s)) (eval (car (cddr s)))))
(defun run-defmacro (s) (gval-table-add (car s) (cons macro (cdr s))))
(defun run-defun (s) (gval-table-add (car s) (run-lambda (cdr s))))
(defun run-lambda (s) (cons lambda s))
(defun run-quote (s) (car s))
(defun run-define (s) (gval-table-add (car s) (eval (cadr s))))

(defun create-val-table (a p) (if a (cons (car a) (cons (eval (car p)) (create-val-table (cdr a) (cdr p)))) ()))
(defun set-vals (a p) (define val-table (create-val-table a p)))

(defun run-func-2 (a b c) b)
(defun run-func-1 (v l s) (run-func-2 (set-vals (car l) s) (eval (cadr l)) (define val-table v)))
(defun run-func (l s) (run-func-1 val-table l s))

(defun create-val-table-m (a p) (if a (cons (car a) (cons (car p) (create-val-table-m (cdr a) (cdr p)))) ()))
(defun set-vals-m (a p) (define val-table (create-val-table-m a p)))

(defun run-macro-2 (a b c) b)
(defun run-macro-1 (v l s) (run-macro-2 (set-vals-m (car l) s) (eval (cadr l)) (define val-table v)))

(defun run-macro (l s) (eval (run-macro-1 val-table l s)))

(defun run-add (s) (+ (eval (car s)) (eval (cadr s))))
(defun run-sub (s) (- (eval (car s)) (eval (cadr s))))
(defun run-mul (s) (* (eval (car s)) (eval (cadr s))))
(defun run-div (s) (/ (eval (car s)) (eval (cadr s))))
(defun run-mod (s) (mod (eval (car s)) (eval (cadr s))))
(defun run-eq (s) (eq (eval (car s)) (eval (cadr s))))
(defun run-car (s) (car (eval (car s))))
(defun run-cdr (s) (cdr (eval (car s))))
(defun run-cons (s) (cons (eval (car s)) (eval (cadr s))))
(defun run-atom (s) (atom (eval (car s))))
(defun run-neg (s) (neg? (eval (car s))))
(defun run-print (s) (print (eval (car s))))

; TEST

;(eval (quote (cons (quote (1 2)) (quote (3 ((5 6)) 4)))))
;(eval (quote (- 3 (+ 3 (if (eq 4 2) (+ 2 (+ 3 2)) (- (+ 4 1) (+ 3 9)))))))

;(define gval-table (table-add gval-table foo hoge))
;(define gval-table (table-add gval-table bar fuga))
;(define gval-table (table-add gval-table foo hige))
;(table-get gval-table foo)

;(eval (quote (defun fizzbuzz (n) (if (eq n 101) nil (if (print (if (eq (mod n 15) 0) FizzBuzz (if (eq (mod n 5) 0) Buzz (if (eq (mod n 3) 0) Fizz n)))) (fizzbuzz (+ n 1)) nil)))))
;(eval (quote (fizzbuzz 1)))



;(eval (quote (* 2 3)))

;(eval (quote (defun f (n) n)))
;(eval (quote (f 42)))

;(eval (quote ((lambda (n) (+ n 4)) 42)))
;(eval (quote (lambda (n) (+ n 4))))

;(eval (quote (define func (lambda (n) (+ n n)))))
;(eval (quote (func 42)))

;(eval (quote (define func (lambda () (print FOO)))))
;(eval (quote (func)))

;(print START)
;(eval (quote (defun mul (n m) (if (eq n 0) 0 (+ m (mul (- n 1) m))))))
;(print DEFINED)
;(eval (quote (print (mul 2 3))))

;(print (run-func-1 1 2 3))

;(eval (quote (print (mul 2 3))))

;(eval (quote (defun mul (n m) (if (eq n 0) 0 (+ m (mul (- n 1) m))))))
;(print START)
;(eval (quote (* 2 3)))


;(define val-table (table-add nil foo hoge))
;(push-vals)
;(print val-stack)
;(pop-vals)
;(print val-stack)

;(eval (quote (define foo 42)))
;(eval (quote foo))

;(eval (quote (defun func (c) 3)))
;(eval (quote (defun func2 (b) (+ (func) b))))
;(eval (quote (defun func2 (b) (+ b (func 99)))))
;(eval (quote (func2 42)))

;(eval (quote (defmacro let (l e) (cons (cons lambda (cons (cons (car l) nil) (cons e nil))) (cons (car (cdr l)) nil)))))
;(eval (quote (let (x 42) x)))
