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

Conflict result caused failed test case:

```
scm> (define x 0)
x
scm> ((define x (+ x 1)) 2)
# Error: str is not callable: x
scm> x
2 (1)
```

## Problem 5

Implement the `quote` special form.

Just return **first** of expr.

