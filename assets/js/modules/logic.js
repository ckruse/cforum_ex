/**
 *  @module logic
 *
 *
 *  @summary
 *
 *  Provides functions for logical operations.
 *
 *
 *  @requires functional
 *
 *  @requires math
 *
 *
 *
 */





import { curry, define } from './functional.js';

import { min } from './math.js';





/**
 *  @function and
 *
 *
 *  @summary
 *
 *  Connects to values with the logical AND operator.
 *
 *
 *  @description
 *
 *  This function takes two operands and applies the logical
 *  and operation on them. That is, if the first value is falsy,
 *  this value is returned, otherwise the it’s the second. There
 *  is no conversion to boolean or any other transformation, so
 *  the values are returned as they are.
 *
 *
 *  @param { * } first
 *
 *  The first operand.
 *
 *
 *  @param { * } second
 *
 *  The second operand.
 *
 *
 *  @return { * }
 *
 *  Either the first or the second value.
 *
 *
 *
 */
export const and = curry(function and (first, second) {
  return first && second;
});




/**
 *  @function both
 *
 *
 *  @summary
 *
 *  Connects two functions with the logical AND operation.
 *
 *
 *  @description
 *
 *  This function takes two functions and returns another function,
 *  whose arity matches that of the operand that takes fewer arguments
 *  and whose name is a concatenation of the word both and the names
 *  of the two function operands. When invoked, this function calls the
 *  first of the two supplied functions with the arguments provided
 *  and if the result is a falsy value, returns that value.
 *
 *
 *  If the result of calling the first function yields a truthy value,
 *  the second function is called and the return value is the value that
 *  is returned from this function. That means, the evaluation of the
 *  operands is short-circuited. If the first function returns a
 *  falsy value, the second one will not be invoked.
 *
 *
 *  @param { function } first
 *
 *  The first function operand.
 *
 *
 *  @param { function } second
 *
 *  The second function operand.
 *
 *
 *  @return { function }
 *
 *  A function that calls one or both function operands.
 *
 *
 *
 */
export const both = curry(function both (first, second) {
  const arity = min(first.length, second.length);

  return curry(define(arity, both.name + first.name + second.name, function () {
    return first.apply(this, arguments) && second.apply(this, arguments);
  }));

});





/**
 *  @function branch
 *
 *
 *  @summary
 *
 *  Calls one or another function depending on a predicate.
 *
 *
 *  @description
 *
 *  This function encapsulates if-else logic. It takes three function
 *  arguments of whom the first one is a predicate function. The second
 *  one is the function that is called when the predicate resolves to
 *  true and the third function is invoked when the peredicate
 *  function returned false.
 *
 *
 *  The function branch returns another function, whose arguments
 *  are used to call the predicate function. Depending on the result,
 *  either the first or the second of the two other functions passed to
 *  branch is called with the same set of arguments. It is very likely
 *  though, that not all three functions expect the same arguments, so
 *  it might make sense to either use partial function application or
 *  to provide a wrapper that calls the respective functions with
 *  the right arguments.
 *
 *
 *  @param { function } predicate
 *
 *  A predicate function.
 *
 *
 *  @param { function } whenTrue
 *
 *  The function to call when the predicate returns a truthy value.
 *
 *
 *  @param { function } whenFalse
 *
 *  The function to call when the predicate returns a falsy value.
 *
 *
 *  @return { function }
 *
 *  A function taking the arguments to be passed in.
 *
 *
 *
 */
export const branch = curry(function branch (predicate, whenTrue, whenFalse) {

  return curry(define(predicate.length, branch.name + predicate.name, function () {
    return (predicate.apply(this, arguments) ? whenTrue : whenFalse).apply(this, arguments);
  }));

});





/**
 *  @function conditions
 *
 *
 *  @summary
 *
 *  Concatenates conditional expressions provided in a list.
 *
 *
 *  @description
 *
 *  This function expects one argument, an array whose elements are
 *  arrays with two elements. The first element of each array provided
 *  is a predicate function and the second element is a function that
 *  gets called when the predicate returns a truthy value.
 *
 *
 *  The return value of conditions is a variadic function that
 *  iterates over the elements of the array of function pairs, calling
 *  the predicate function of each pair with the arguments that’s been
 *  passed to it. If one predicate returns a truthy value, then the
 *  associated function is also called with the same arguments.
 *
 *
 *  In this case the iteration will be stopped and the value returned
 *  from this function call will be the result of the whole expression.
 *  The remaining functions in the list are not called anymore. If
 *  no predicate returns true, then false will be returned.
 *
 *
 *  @param { Array [] } pairs
 *
 *  An array of function pairs.
 *
 *
 *  @return { function }
 *
 *  A function taking the arguments to test against.
 *
 *
 *
 */
export const conditions = curry(function conditions (pairs) {

  return function () {
    let result = false;

    pairs.some(([predicate, action]) => {
      const value = predicate.apply(this, arguments);

      if (value) {
        result = action.apply(this, arguments);
      }

      return value;
    });

    return result;
  };

});





/**
 *  @function complement
 *
 *
 *  @summary
 *
 *  Takes a predicate function and negates the result.
 *
 *
 *  @description
 *
 *  This function takes a predicate and returns another function
 *  that when invoked calls the predicate with the provided arguments
 *  and applies the logical NOT operation to its result. For example,
 *  calling complement with equal will produce a function which tests
 *  not for equality but for inequality. The function returned from
 *  complement has the same arity as the predicate and the name is
 *  a concatenation of the word not and the predicate name.
 *
 *
 *  @param { function } predicate
 *
 *  A predicate function.
 *
 *
 *  @return { boolean }
 *
 *  The negation of the value returned from predicate.
 *
 *
 *
 */
export const complement = curry(function complement (predicate) {

  return curry(define(predicate.length, not.name + predicate.name, function () {
    return not(predicate.apply(this, arguments));
  }));

});





/**
 *  @function either
 *
 *
 *  @summary
 *
 *  Connects two functions with the logical OR operation.
 *
 *
 *  @description
 *
 *  This function takes two functions and returns another function,
 *  whose arity matches that of the operand that takes fewer arguments
 *  and whose name is a concatenation of the word either and the names
 *  of the two function operands. When invoked, this function calls the
 *  first of the two supplied functions with the arguments provided
 *  and if the result is a truthy value, returns that value.
 *
 *
 *  If the result of calling the first function yields a falsy value,
 *  the second function is called and the return value is the value that
 *  is returned from this function. That means, the evaluation of the
 *  operands is short-circuited. If the first function returns a
 *  truthy value, the second one will not be invoked.
 *
 *
 *  @param { function } first
 *
 *  The first function operand.
 *
 *
 *  @param { function } second
 *
 *  The second function operand.
 *
 *
 *  @return { function }
 *
 *  A function that calls one or both function operands.
 *
 *
 *
 */
export const either = curry(function either (first, second) {
  const arity = min(first.length, second.length);

  return curry(define(arity, either.name + first.name + second.name, function () {
    return first.apply(this, arguments) || second.apply(this, arguments);
  }));

});





/**
 *  @function not
 *
 *
 *  @summary
 *
 *  Applies the logical NOT Operator to a value.
 *
 *
 *  @description
 *
 *  This is a unary function that simply applys the logical not
 *  operator to its argument. In this operation, the provided value
 *  is coerced to boolean and if the result is true, false is
 *  returned, and vice versa.
 *
 *
 *  @param { * } value
 *
 *  The value to negate.
 *
 *
 *  @return { boolean }
 *
 *  A boolean value.
 *
 *
 *
 */
export const not = curry(function not (value) {
  return !value;
});





/**
 *  @function or
 *
 *
 *  @summary
 *
 *  Connects two values with the logical OR Operator.
 *
 *
 *  @description
 *
 *  This function takes two operands and applies the logical
 *  or operation on them. That is, if the first value is truthy,
 *  this value is returned, otherwise the it’s the second. There
 *  is no conversion to boolean or any other transformation, so
 *  the values are returned as they are.
 *
 *
 *  @param { * } first
 *
 *  The first operand.
 *
 *
 *  @param { * } second
 *
 *  The second operand.
 *
 *
 *  @return { * }
 *
 *  Either the first or the second value.
 *
 *
 *
 */
export const or = curry(function or (first, second) {
  return first || second;
});





/**
 *  @function unless
 *
 *
 *  @summary
 *
 *  Calls a function if a test failed.
 *
 *
 *  @description
 *
 *  This function takes three arguments, two functions and an
 *  arbitrary value. The first function is a predicate that gets
 *  called with the provided value first. If it returns a falsy
 *  value, the second function gets called with the value and its
 *  result is returned. Otherwise the value the unless function
 *  has been called with is returned.
 *
 *
 *  @param { function } predicate
 *
 *  A predicate function.
 *
 *
 *  @param { function } action
 *
 *  A function to execute when the test failed.
 *
 *
 *  @param { * } value
 *
 *  The value to invoke both functions with.
 *
 *
 *  @return { * }
 *
 *  Either the result of calling action or the provided value.
 *
 *
 *
 */
export const unless = curry(function unless (predicate, action, value) {
  return predicate(value) ? value : action(value);
});





/**
 *  @function when
 *
 *
 *  @summary
 *
 *  Calls a function when a test is passed.
 *
 *
 *  @description
 *
 *  This function takes three arguments, two functions and an
 *  arbitrary value. The first function is a predicate that gets
 *  called with the provided value first. If it returns a truthy
 *  value, the second function gets called with the value and its
 *  result is returned. Otherwise the value the when function
 *  has been called with is returned.
 *
 *
 *  @param { function } predicate
 *
 *  A predicate function.
 *
 *
 *  @param { function } action
 *
 *  A function to execute when the test was passed.
 *
 *
 *  @param { * } value
 *
 *  The value to invoke both functions with.
 *
 *
 *  @return { * }
 *
 *  Either the result of calling action or the provided value.
 *
 *
 *
 */
export const when = curry(function when (predicate, action, value) {
  return predicate(value) ? action(value) : value;
});
