import sys
import os

from pair import *
from scheme_utils import *
from ucb import main, trace

import scheme_forms
import functools

##############
# Eval/Apply #
##############


def scheme_eval(expr, env, _=None):  # Optional third argument is ignored
    """Evaluate Scheme expression EXPR in Frame ENV.

    >>> expr = read_line('(+ 2 2)')
    >>> expr
    Pair('+', Pair(2, Pair(2, nil)))
    >>> scheme_eval(expr, create_global_frame())
    4
    """
    # Evaluate atoms
    if scheme_symbolp(expr):
        return env.lookup(expr)
    elif self_evaluating(expr):
        return expr

    # All non-atomic expressions are lists (combinations)
    if not scheme_listp(expr):
        raise SchemeError('malformed list: {0}'.format(repl_str(expr)))
    first, rest = expr.first, expr.rest
    if scheme_symbolp(first) and first in scheme_forms.SPECIAL_FORMS:
        return scheme_forms.SPECIAL_FORMS[first](rest, env)
    else:
        # BEGIN PROBLEM 3
        "*** YOUR CODE HERE ***"
        if isinstance(first, Pair):  # (print-then-return 1 +)
            first_cloned = scheme_eval(first, env)
        else:
            first_cloned = first

        eval_operands = True
        if isinstance(first_cloned, Procedure):  # print-then-return
            procedure = first_cloned
        else:
            procedure = env.lookup(first_cloned)
            if isinstance(procedure, MacroProcedure):
                eval_operands = False

        if eval_operands:
            rest_cloned = rest.map(functools.partial(scheme_eval, env=env))
            return scheme_apply(procedure, rest_cloned, env)
        else:
            rest_cloned = rest
            target_expr = scheme_apply(procedure, rest_cloned, env)
            return scheme_eval(target_expr, env)  # eval the target expr
        # END PROBLEM 3


def scheme_apply(procedure, args, env):
    """Apply Scheme PROCEDURE to argument values ARGS (a Scheme list) in
    Frame ENV, the current environment."""
    validate_procedure(procedure)
    if isinstance(procedure, BuiltinProcedure):
        # BEGIN PROBLEM 2
        "*** YOUR CODE HERE ***"
        arg_list = []
        if args != nil:
            while args.rest != nil:
                arg_list.append(args.first)
                args = args.rest
            arg_list.append(args.first)
        if procedure.expect_env:
            arg_list.append(env)
        try:
            return procedure.py_func(*arg_list)
        except TypeError:
            raise SchemeError('incorrect number of arguments')
        # END PROBLEM 2
    elif isinstance(procedure, LambdaProcedure):
        # BEGIN PROBLEM 9
        "*** YOUR CODE HERE ***"
        reversed_vals = nil
        reversed_formals = nil
        formals = Pair(procedure.formals.first, procedure.formals.rest)
        for _ in range(len(formals)):
            reversed_formals = Pair(formals.first, reversed_formals)
            reversed_vals = Pair(args.first, reversed_vals)
            formals = formals.rest
            args = args.rest
        child_frame = procedure.env.make_child_frame(reversed_formals, reversed_vals)
        return eval_all(procedure.body, child_frame,
                        False if isinstance(procedure, MacroProcedure) else True)  # eval immediately
        # END PROBLEM 9
    elif isinstance(procedure, MuProcedure):
        # BEGIN PROBLEM 11
        "*** YOUR CODE HERE ***"
        reversed_vals = nil
        reversed_formals = nil
        formals = Pair(procedure.formals.first, procedure.formals.rest)
        for _ in range(len(formals)):
            reversed_formals = Pair(formals.first, reversed_formals)
            reversed_vals = Pair(scheme_eval(args.first, env), reversed_vals)
            formals = formals.rest
            args = args.rest
        child_frame = env.make_child_frame(reversed_formals, reversed_vals)  # note env
        return eval_all(procedure.body, child_frame)
        # END PROBLEM 11
    else:
        assert False, "Unexpected procedure: {}".format(procedure)


def eval_all(expressions, env, tail=True):
    """Evaluate each expression in the Scheme list EXPRESSIONS in
    Frame ENV (the current environment) and return the value of the last.

    >>> eval_all(read_line("(1)"), create_global_frame())
    1
    >>> eval_all(read_line("(1 2)"), create_global_frame())
    2
    >>> x = eval_all(read_line("((print 1) 2)"), create_global_frame())
    1
    >>> x
    2
    >>> eval_all(read_line("((define x 2) x)"), create_global_frame())
    2
    """
    # BEGIN PROBLEM 6
    assert scheme_listp(expressions)
    if expressions == nil:
        return None

    expr_cloned = Pair(expressions.first, expressions.rest)
    while expr_cloned.rest != nil:
        scheme_eval(expr_cloned.first, env)
        expr_cloned = expr_cloned.rest
    return scheme_eval(expr_cloned.first, env, tail)
    # END PROBLEM 6


##################
# Tail Recursion #
##################

class Unevaluated:
    """An expression and an environment in which it is to be evaluated."""

    def __init__(self, expr, env):
        """Expression EXPR to be evaluated in Frame ENV."""
        self.expr = expr
        self.env = env


def complete_apply(procedure, args, env):
    """Apply procedure to args in env; ensure the result is not an Unevaluated."""
    validate_procedure(procedure)
    val = scheme_apply(procedure, args, env)
    if isinstance(val, Unevaluated):
        return scheme_eval(val.expr, val.env)
    else:
        return val


def optimize_tail_calls(original_scheme_eval):
    """Return a properly tail recursive version of an eval function."""
    def optimized_eval(expr, env, tail=False):
        """Evaluate Scheme expression EXPR in Frame ENV. If TAIL,
        return an Unevaluated containing an expression for further evaluation.
        """
        if tail and not scheme_symbolp(expr) and not self_evaluating(expr):
            return Unevaluated(expr, env)

        result = Unevaluated(expr, env)
        # BEGIN PROBLEM EC
        "*** YOUR CODE HERE ***"
        while isinstance(result, Unevaluated):
            result = original_scheme_eval(result.expr, result.env)
        return result
        # END PROBLEM EC
    return optimized_eval


################################################################
# Uncomment the following line to apply tail call optimization #
################################################################
scheme_eval = optimize_tail_calls(scheme_eval)
