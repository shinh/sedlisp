SedLisp
=======

Lisp implementation in (GNU) sed


How to Use
----------

    $ sed -f sedlisp.sed  # '>' won't be shown.
    > (car (quote (a b c)))
    a
    > (cdr (quote (a b c)))
    (b c)
    > (cons 1 (cons 2 (cons 3 ())))
    (1 2 3)
    > (defun fact (n) (if (eq n 0) 1 (* n (fact (- n 1)))))
    (lambda (n) (if (eq n 0) 1 (* n (fact (- n 1)))))
    > (fact 10)
    3628800
    > (defun fib (n) (if (eq n 1) 1 (if (eq n 0) 1 (+ (fib (- n 1)) (fib (- n 2))))))
    (lambda (n) (if (eq n 1) 1 (if (eq n 0) 1 (+ (fib (- n 1)) (fib (- n 2))))))
    > (fib 12)
    233
    > (defun gen (n) ((lambda (x y) y) (define G n) (lambda (m) (define G (+ G m)))))
    (lambda (n) ((lambda (x y) y) (define G n) (lambda (m) (define G (+ G m)))))
    > (define x (gen 100))
    (lambda (m) (define G (+ G m)))
    > (x 10)
    110
    > (x 90)
    200
    > (x 300)
    500


Builtin Functions
-----------------

- car
- cdr
- cons
- eq
- atom
- +, -, *, /, mod
- neg?
- print


Special Forms
-------------

- quote
- if
- lambda
- defun
- define


Special Forms
-------------

- quote
- if
- lambda
- defun
- define


More Complicated Examples
-------------------------

You can test a few more examples.

FizzBuzz:

    $ cat fizzbuzz.l | sed -f sedlisp.sed
    (lambda (n) (if (eq n 101) nil (if (print (if (eq (mod n 15) 0) FizzBuzz (if (eq (mod n 5) 0) Buzz (if (eq (mod n 3) 0) Fizz n)))) (fizzbuzz (+ n 1)) nil)))
    PRINT: 1
    PRINT: 2
    PRINT: Fizz
    ...
    PRINT: 98
    PRINT: Fizz
    PRINT: Buzz
    nil

Sort:

    $ cat sort.l /dev/stdin | sed -f sedlisp.sed
    ...
    (sort (quote (4 2)))
    (2 4)
    (sort (quote (4 2 99 12 -4 -7)))
    (-7 -4 2 4 12 99)

Though this Lisp implementation does not support eval function, we can
implement eval on top of this interpreter - eval.l is the
implementation:

    $ cat eval.l /dev/stdin | sed -f sedlisp.sed
    (eval (quote (+ 4 38)))
    42
    (eval (quote (defun fact (n) (if (eq n 0) 1 (* n (fact (- n 1)))))))
    (fact (lambda (n) (if (eq n 0) 1 (* n (fact (- n 1))))))
    (eval (quote (fact 4)))  ; Takes 10 seconds or so.
    24

This essentially means we have a Lisp interpreter in Lisp. evalify.rb
is a helper script to convert a normal Lisp program into the Lisp in
Lisp. You can run the FizzBuzz program like:

    $ ./evalify.rb fizzbuzz.l | sed -f sedlisp.sed
    ...
    PRINT: 1
    PRINT: 2
    PRINT: Fizz

This takes very long time. For me, it took 45 minutes.

Though sedlisp.sed does not support defmacro, eval.l also defines
defmacro:

    $ ./evalify.rb | sed -f sedlisp.sed
    (defmacro let (l e) (cons (cons lambda (cons (cons (car l) nil) (cons e nil))) (cons (car (cdr l)) nil)))
    (let (x 42) (+ x 7))  ; Hit ^d after this.
    ...
    49
    $ ./evalify.rb | sed -f sedlisp.sed
    (defun list0 (a) (cons a nil))
    (defun cadr (a) (car (cdr a)))
    (defmacro cond (l) (if l (cons if (cons (car (car l)) (cons (cadr (car l)) (cons (cons (quote cond) (list0 (cdr l))))))) nil))
    (defun fb (n) (cond (((eq (mod n 5) 0) "Buzz") ((eq (mod n 3) 0) "Fizz") (t n))))
    (fb 18)  ; Hit ^d after this. This will take about one minute.
    ...
    Fizz

Unfortunately, you cannot nest the eval one more time. This is
probably a limitation of eval.l.

test.l is the test program I was using during the development. test.rb
runs it with sedlisp.sed and purelisp.rb and compare their
results. You can run the test with evalify.rb by passing -e:

    $ ./test.rb -e


Limitations
-----------

There should be a lot of limitations. sedlisp behaves very strangely
when you pass a broken Lisp code.

I don't know how many GNU extensions I used, so it would not be easy
to port this to other sed implementations.
