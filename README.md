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

## Problem 1

Implement the `define` and `lookup` methods of the Frame class.

Use **mapping** to simulate the frame.

## Problem 2

Implement `scheme_apply` BuiltinProcedure.

Convert args from **pair** representation to **list** representation.

Append *env* if exists.

## Problem 3

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

## Problem 4

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

## Problem 5

Implement the `quote` special form.

Just return **first** of expression.

## Problem 6

Implement `eval_all` for the `begin` special form.

- evaluating all sub-expressions in order
- the value of the final sub-expression is return value

note:

- expressions maybe nil
- expressions should be immutable

## Problem 7

Implement the `do_lambda_form` function.

Just construct the `LambdaProcedure`.

ok crashed again...

```
NameError: name 'do_lambda_form' is not define
```

## Problem 8

Implement the `make_child_frame` method.

- construct `Frame`
- formal -> val
