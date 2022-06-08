# Scheme Interpreter

## Source

https://nju-sicp.bitbucket.io/projs/proj04

## Run

```commandline
python3 scheme.py
```

## Test

- unlock the test first
- enter the correct output

```commandline
python3 ok -q xxx -u
python3 ok -q xxx
```

## Note

### Problem 1

Implement the `define` and `lookup` methods of the Frame class.

Use **mapping** to simulate the frame.

### Problem 2

Implement `scheme_apply` BuiltinProcedure.

Convert args from **pair** representation to **list** representation.

Append *env* if exists.

### Problem 3

Implement `scheme_eval` builtin call expression.

1. Evaluate the operator.

two forms of `expr.first`:

- str, e.g. `(print-then-return 1 +)`
  - may return `BuiltinProcedure`
- pair, e.g. `+`
  - scan `scheme_builtins.BUILTINS` to find the procedure
  - can be simplified to `env.lookup`, note `eval` not in `scheme_builtins.BUILTINS`

2. Evaluate all the operands.

`rest.map(functools.partial(scheme_eval, env=env))`

3. Apply the procedure on the evaluated operands.

### Problem 4

Implement the `define` special form like `(define a (+ 2 3))`.

Simply `scheme_eval` the **rest** and `define` for **first**.

Cok crashed...

```
scm> (define x 0)
x
scm> ((define x (+ x 1)) 2)
# Error: str is not callable: x
scm> x
2 (shoule be 1)
```

### Problem 5

Implement the `quote` special form.

Just return **first** of expression.

### Problem 6

Implement `eval_all` for the `begin` special form.

- evaluating all sub-expressions in order
- the value of the final sub-expression is return value

note:

- expressions maybe nil
- expressions should be immutable

### Problem 7

Implement the `do_lambda_form` function.

Just construct the `LambdaProcedure`.

ok crashed again...

```
NameError: name 'do_lambda_form' is not define
```

### Problem 8

Implement the `make_child_frame` method.

- `parent = self`
- `bindings[formal] = val`

### Problem 9

Implement `scheme_apply` LambdaProcedure.

- new frame should be a child of the frame in which the lambda is defined
- call `scheme_eval` with `env` to get `arg -> val`

### Problem 10

Implement the `define` special form like `(define (f x) (* x 2))`.

- Convert to `(define f (lambda (x) (* x 2)))`. 
- Create `LambdaProcedure` and bind the symbol to it.

### Problem 11

Implement `do_mu_form` and `scheme_apply` MuProcedure.

- lexical scoping: the parent of the new call frame is the environment in which the procedure was **defined**
- dynamic scoping: the parent of the new call frame is the environment in which the call expression was **evaluated**

dynamic scoping example:

```
scm> (define f (mu () (* a b)))
f
scm> (define g (lambda () (define a 4) (define b 5) (f)))
g
scm> (g)
20
```

### Problem 12

Implement `do_and_form` and `do_or_form`.

- evaluate each sub-expression from left to right
- if any of these is a false (`and`) / true (`or`) value, return that value
- otherwise, return the value of the last sub-expression
- if there are no sub-expressions, evaluates to #t (`and`) / #f (`or`)

### Problem 13

Implement `do_cond_form`.

Just `eval_all`.

