/**
 *  @module functional
 *
 *
 *  @summary
 *
 *  Provides functions to support functional programming.
 *
 *
 *  @description
 *
 *  The functions exported from this module can be seen as building
 *  blocks for the implementation of the application specific program
 *  logic. The majority of the functions defined in this module are
 *  higher order functions serving as operators for other functions.
 *  Use cases covered by the members of this module include for
 *  example function composition, partial function application,
 *  guards and combinators.
 *
 *
 *  With the sole exception of the so called define function, all
 *  functions that do have at least one required formal parameter are
 *  curried. That means, they can be invoked with less arguments than
 *  neccessary and in this case, a function will be returned, which
 *  takes the remaining arguments and then calls the curried function
 *  or returns another function to collect missing values. That
 *  also holds true for closures, which are returned from some
 *  of the exported functions.
 *
 *
 *  As a general rule, functions that invoke other functions passed
 *  in as arguments will call these functions with the function context
 *  they themselves have been initialized with. However, though this
 *  practice enables the functions on hand to be used in connection
 *  with object methods, this kind of usage should be avoided
 *  wherever possible.
 *
 *
 +  The reason for this advice is that a function that reaches out
 *  for a context object does lack the property of being referencially
 *  transparent, which essentially means, that the call to a function
 *  can be replaced by its result without changing the state of the
 *  program. Functions that only process their arguments and always
 *  return the same output for the same input are way easier to
 *  test, and also improve the readability of the code.
 *
 *
 *  @requires math
 *
 *  @requires predicates
 *
 *
 *
 */





import { max } from './math.js';

import { equal } from './predicates.js';





/**
 *  @function apply
 *
 *
 *  @summary
 *
 *  Calls a function with arguments provided in a list.
 *
 *
 *  @description
 *
 *  This is mostly an alias for the native apply method, but other
 *  than that method, this one does not expect a value for the function
 *  context. Instead the target function will be called with the context
 *  that apply has been initialized with. In addition, the argument that
 *  is passed after the target function does not have to be an array or
 *  array-like object, it can be any object that is iterable.
 *
 *
 *  @param { function } target
 *
 *  The function to call.
 *
 *
 *  @param { Iterable } values
 *
 *  List of arguments for target.
 *
 *
 *  @return { * }
 *
 *  The result of calling target with values.
 *
 *
 *
 */
export const apply = curry(function apply (target, [...values]) {
  return target.apply(this, values);
});





/**
 *  @function binary
 *
 *
 *  @summary
 *
 *  Converts a function of any arity into a binary function.
 *
 *
 *  @description
 *
 *  When called with a function, it returns another function that takes
 *  two arguments. The target function provided to binary is then called
 *  with the first two values passed to the function returned. All other
 *  arguments that may be supplied are ignored, so the target function
 *  is effectively transformed into a binary function.
 *
 *
 *  @param { function } target
 *
 *  The function to call with two arguments.
 *
 *
 *  @return { function }
 *
 *  A binary function that calls target with its first two arguments.
 *
 *
 *
 */
export const binary = curry(function binary (target) {

  return curry(define(2, binary.name + target.name, function (first, second) {
    return target.call(this, first, second);
  }));

});





/**
 *  @function call
 *
 *
 *  @summary
 *
 *  Invokes a function with arguments.
 *
 *
 *  @description
 *
 *  This function is much like the native call method, but it does
 *  not require a value to initialize the function context with. The
 *  target function is invoked with the context of call instead. As with
 *  the native method, any number of arguments passed to call after the
 *  first argument are used to call the target function, and the
 *  return value is the result of this function call.
 *
 *
 *  @param { function } target
 *
 *  The function to call.
 *
 *
 *  @param { ...* } values
 *
 *  Arguments to call target with.
 *
 *
 *  @return { * }
 *
 *  The result of calling target.
 *
 *
 *
 */
export const call = curry(function call (target, ...values) {
  return target.apply(this, values);
});





/**
 *  @function compose
 *
 *
 *  @summary
 *
 *  Performs right to left function composition.
 *
 *
 *  @description
 *
 *  When called with two function arguments and an arbitrary number of
 *  additional values of any type, calls the function provided as the second
 *  argument with all arguments coming next in the list. Then the function
 *  that has been passed in as the first argument is called with the result
 *  of that invokation and its value is returned.
 *
 *
 *  @param { function } outer
 *
 *  The function to call with the result of the inner function.
 *
 *
 *  @param { function } inner
 *
 *  The function to call with values.
 *
 *
 *  @param { ...* } values
 *
 *  The values to call the inner function.
 *
 *
 *  @return { * }
 *
 *  The value returned from the outer function.
 *
 *
 *
 */
export const compose = curry(function compose (outer, inner, ...values) {
  return outer(inner.apply(this, values));
});





/**
 *  @function constant
 *
 *
 *  @summary
 *
 *  Produces a function that always returns the same value.
 *
 *
 *  @description
 *
 *  The constant function takes a single value and returns a
 *  function that ignores all arguments and always returns the
 *  value provided to constant. If this is not a primitive value
 *  every invokation will yield a reference to the same object
 *  and not a copy thereof.
 *
 *
 *  @param { * } value
 *
 *  The value to encapsulate in a function.
 *
 *
 *  @return { function }
 *
 *  The function that returns the given value.
 *
 *
 *
 */
export const constant = curry(function constant (value) {
  return () => value;
});





/**
 *  @function curry
 *
 *
 *  @summary
 *
 *  Applies auto-currying to its function operand.
 *
 *
 *  @description
 *
 *  The result of the operation is that the target function passed
 *  to curry can be called with less arguments than required. In this
 *  case a function is returned which takes the remaining arguments.
 *  This is repeated until all arguments are provided and then the
 *  target function gets called with the collected values.
 *
 *
 *  The optional second parameter must be an array if specified. The
 *  values contained in the array are then mapped to the parameters the
 *  parameter list of the target function starts with, in the same
 *  order they appear in the array.
 *
 *
 *  Though initially defined as anonymous functions, the intermediate
 *  functions returned by curry have the same name as the function that
 *  is curried. Additionally, the length property of the returned
 *  functions reflects the number of missing arguments.
 *
 *
 *  @param { function } target
 *
 *  The function to be curried.
 *
 *
 *  @param { Array } [ list = [] ]
 *
 *  An array with arguments passed to target.
 *
 *
 *  @return { function }
 *
 *  The curried target function.
 *
 *
 *
 */
export function curry (target, list = []) {

  if (target) {

    return define(target.length - list.length, target.name, function () {
      const values = list.concat([...arguments]);

      return target.length <= values.length ? target.apply(this, values) : curry(target, values);
    });

  }

  return curry;
}





/**
 *  @function define
 *
 *
 *  @summary
 *
 *  Sets the length and name properties of a function.
 *
 *
 *  @description
 *
 *  Some higher order functions like curry require that a given
 *  function has a fixed arity, which is represented by the length
 *  property of function objects. In other cases specifying the number
 *  of arguments expected by a function is not technically needed,
 *  but it is a valueable information provided to the caller.
 *
 *
 *  For the same reason it can be desireable to assign an otherwise
 *  anonymous function a specific name. As an example, this name can be
 *  used by capable browsers to improve their debugging tools, such
 *  that it is displayed in a stack trace when an error occured.
 *
 *
 *  Because neither length nor name are writable by default, their
 *  values cannot be changed through simple assignment. Instead, both
 *  properties must be explicitly defined. As for consistency, this
 *  function only changes the value attribute of each property, so
 *  future changes will also need explicit definition.
 *
 *
 *  Please note that this function is not auto-curried, so calling
 *  it with less arguments than required will cause an exception to be
 *  thrown. That’s because the curry function itself depends on this
 *  function. Maybe this can be changed in the future but until
 *  now, care must be taken in this regard.
 *
 *
 *  @param { number } length
 *
 *  The number representing the arity of the function.
 *
 *
 *  @param { string } name
 *
 *  The name of the function.
 *
 *
 *  @param { function } target
 *
 *  The function whose properties to change.
 *
 *
 *  @return { function }
 *
 *  The augmented target function.
 *
 *
 *
 */
export function define (length, name, target) {
  return Object.defineProperties(target, {

    length: {
      configurable: true,
      value: max(length, 0)
    },

    name: {
      configurable: true,
      value: name
    }

  });
}





/**
 *  @function defineFrom
 *
 *
 *  @summary
 *
 *  Sets length and name of a function to match another function.
 *
 *
 *  @description
 *
 *  This is just a shorthand for the define function which can be
 *  used when a function needs to get assigned the values of the length
 *  and name properties of another function. Calling define clutters
 *  function definitions badly so this one should be used when it’s
 *  only about copying values.
 *
 *
 *  @param { function } source
 *
 *  The template function.
 *
 *
 *  @param { function } target
 *
 *  The function whose properties to change.
 *
 *
 *  @return { function }
 *
 *  The augmented function object.
 *
 *
 *
 */
export const defineFrom = curry(function defineFrom (source, target) {
  return define(source.length, source.name, target);
});







/**
 *  @function falsy
 *
 *
 *  @summary
 *
 *  A function that always returns false.
 *
 *
 *  @description
 *
 *  Calling falsy always yields the primitive value false. All
 *  arguments passed to this function as well as the context it
 *  is initialized with are ignored. This is just a shorthand
 *  for situations where a function is expected and not the
 *  value itself.
 *
 *
 *  @return { boolean }
 *
 *  The boolean value false.
 *
 *
 *
 */
export function falsy () {
  return false;
}





/**
 *  @function flip
 *
 *
 *  @summary
 *
 *  Changes the order of arguments for a function.
 *
 *
 *  @description
 *
 *  The function returned from flip expects the same number of
 *  arguments as the target function provided, but in reverse order.
 *  When invoked, the arguments list is flipped and the values are
 *  passed to the target function. The return value of the returned
 *  function is the result of calling the target function.
 *
 *
 *  @param { function } target
 *
 *  The function whose parameter list to flip.
 *
 *
 *  @return { function }
 *
 *  A wrapper for target with flipped parameters.
 *
 *
 *
 */
export const flip = curry(function flip (target) {

  return curry(defineFrom(target, function () {
    return target.apply(this, [...arguments].reverse());
  }));

});





/**
 *  @function identity
 *
 *
 *  @summary
 *
 *  Returns the value which it was called with.
 *
 *
 *  @description
 *
 *  The identity function is a unary function that does nothing
 *  else than returning its parameters value. Any other argument
 *  passed to identity as well as the function context are ignored.
 *  The identity function can act as a placeholder where a
 *  function but no further logic is needed.
 *
 *
 *  @param { * } value
 *
 *  The value to return when called.
 *
 *
 *  @return { * }
 *
 *  The value identity was called with.
 *
 *
 *
 */
export const identity = curry(function identity (value) {
  return value;
});





/**
 *  @function memoize
 *
 *
 *  @summary
 *
 *  Caches results of previous function calls.
 *
 *
 *  @description
 *
 *  This function takes a target function and returns a guard,
 *  which intercepts the calls to target. If for a given set of
 *  arguments the target function has already been invoked, then
 *  the guard will not call target but return directly the cached
 *  result of that previous call. If the arguments do not match,
 *  target is called and the result is cached before being
 *  returned to the caller.
 *
 *
 *  It should be mentioned though that memoization comes not for
 *  free, because cache lookups are a costy operation itself. So it
 *  is advisable to only use this function for operations that have
 *  a big impact on performance or are not called very often. In
 *  addition, it should be kept in mind that caching results like
 *  this is obviously no option if the target function is not
 *  referencially transparent.
 *
 *
 *  @param { function } target
 *
 *  The function to memoize.
 *
 *
 *  @return { function }
 *
 *  A function that caches in and out values for target.
 *
 *
 *
 */
export const memoize = curry(function memoize (target) {
  const cache = [];

  return curry(defineFrom(target, function () {
    const list = [...arguments];

    for (let [array, value] of cache) {
      if (array.every((argument, index) => equal(list[index], argument))) {
        return value;
      }
    }

    const value = target.apply(this, list);
    cache.push([list, value]);

    return value;
  }));

});





/**
 *  @function once
 *
 *
 *  @summary
 *
 *  Restricts the number of calls to its operand to one.
 *
 *
 *  @description
 *
 *  The function once takes another function as argument and returns
 *  a guard for this function. The first time the guard is invoked, it
 *  stores the result of calling the operand. In this and all subsequent
 *  calls the stored value is returned. The function passed to once is
 *  never called again.
 *
 *
 *  @param { function } target
 *
 *  The function to guard.
 *
 *
 *  @return { function }
 *
 *  A function that calls target only once.
 *
 *
 *
 */
export const once = curry(function once (target) {
  let result, called = false;

  return curry(define(target.length, once.name + target.name, function () {
    return called ? result : (called = true, result = target.apply(this, arguments));
  }));

});





/**
 *  @function partial
 *
 *
 *  @summary
 *
 *  This function partially applies its operand.
 *
 *
 *  @description
 *
 *  Partial function application means binding a certain number of
 *  arguments to a function. The result is a function with smaller arity
 *  than the original function, which takes the missing values. Those
 *  values together with the initially provided arguments are then
 *  passed to the original function.
 *
 *
 *  @param { function } target
 *
 *  The function to partially apply.
 *
 *
 *  @param { ...* } values
 *
 *  Any number of arguments to bind to the target function.
 *
 *
 *  @return { function }
 *
 *  A function that takes the remaining arguments.
 *
 *
 *
 */
export const partial = curry(function partial (target, ...values) {

  return curry(define(target.length - values.length, target.name, function () {
    return target.apply(this, values.concat([...arguments]));
  }));

});





/**
 *  @function partialReversed
 *
 *
 *  @summary
 *
 *  Performs reversed partial function application.
 *
 *
 *  @description
 *
 *  This function is basically the same as the partial function. The
 *  sole Difference is the order in which the arguments are passed to
 *  the target function. With partialReversed those values initially
 *  provided are passed to target after the arguments the returned
 *  function has been called with.
 *
 *
 *  @param { function } target
 *
 *  The function to partially apply.
 *
 *
 *  @param { ...* } values
 *
 *  The last arguments to be passed to the target function.
 *
 *
 *  @return { function }
 *
 *  A function that takes the first arguments for target.
 *
 *
 *
 */
export const partialReversed = curry(function partialReversed (target, ...values) {

  return curry(define(target.length - values.length, target.name, function () {
    return target.apply(this, [...arguments, ...values]);
  }));

});





/**
 *  @function pipe
 *
 *
 *  @summary
 *
 *  Performs left to right function composition.
 *
 *
 *  @description
 *
 *  This function takes one or more functions as arguments and returns
 *  another function which composes these functions to a single call. The
 *  first function supplied to pipe may be variadic and is invoked with
 *  the arguments the composing function has been called with.
 *
 *
 *  If pipe is called with more than one function argument, then the
 *  other functions are called in line from left to right with the return
 *  value of the function previous in the arguments list. That means all
 *  functions provided other than the first one must be unary.
 *
 *
 *  @param { function } start
 *
 *  The mandatory first function to call.
 *
 *
 *  @param { ...function } list
 *
 *  An arbitrary number of functions to call after start.
 *
 *
 *  @return { function }
 *
 *  A function that takes the arguments to initialize the sequence.
 *
 *
 *
 */
export const pipe = curry(function pipe (start, ...list) {

  return curry(define(start.length, pipe.name + start.name, function () {
    const initializer = start.apply(this, arguments);

    return list.length ? list.reduce((value, target) => target(value), initializer) : initializer;
  }));

});





/**
 *  @function prepare
 *
 *
 *  @summary
 *
 *  Transforms arguments before calling a function with them.
 *
 *
 *  @description
 *
 *  When invoked, prepare takes a target function as its first argument
 *  and an array of functions in second place. It returns a function of the
 *  same arity and name as the target function. This function maps the list
 *  of functions to the list of its arguments, such that each argument is
 *  passed to the function having the same index in the list. Then the
 *  target function is invoked with the transformed values.
 *
 *
 *  In case the function returned from prepare is called with more values
 *  than functions were provided, the remaining arguments are appended to the
 *  list of values the target function gets called with. If there are fewer
 *  arguments than functions and than expected by the target function, some
 *  functions will be called with the undefined value, which is most
 *  likely no desired behavior, so care must be taken.
 *
 *
 *  @param { function } target
 *
 *  The function to call with transformed arguments.
 *
 *
 *  @param { function [] } transformers
 *
 *  An array of transformer functions.
 *
 *
 *  @return { functions }
 *
 *  Function that receives the arguments to transform.
 *
 *
 *
 */
export const prepare = curry(function prepare (target, transformers) {

  return curry(defineFrom(target, function () {
    let values = transformers.map((target, index) => target.call(this, arguments[index]));

    if (arguments.length > transformers.length) {
      values = values.concat([...arguments].slice(transformers.length));
    }

    return target.apply(this, values);
  }));

});





/**
 *  @function substitute
 *
 *
 *  @summary
 *
 *  Performs functional substitution.
 *
 *
 *  @description
 *
 *  The function expects two function arguments and an arbitrary number
 *  of additional values of any type. It first applies the provided values to
 *  the function passed in as the first argument. This must be a higher order
 *  function returning another function. That function in turn is applied to
 *  the result of calling the second function provided to substitute, with
 *  the same arguments the first function had been called before.
 *
 *
 *  @param { function } first
 *
 *  A function that’s called with values and returns another function.
 *
 *
 *  @param { function } second
 *
 *  A function thats called with values.
 *
 *
 *  @param { ...* } values
 *
 *  An arbitrary number of values of any type.
 *
 *
 *  @return { * }
 *
 *  The result of calling the function returned from first.
 *
 *
 *
 */
export const substitute = curry(function (first, second, ...values) {
  return first.apply(this, values)(second.apply(this, values));
});





/**
 *  @function ternary
 *
 *
 *  @summary
 *
 *  Converts a function of any arity into a ternary function.
 *
 *
 *  @description
 *
 *  When called with a function, it returns another function that takes
 *  three arguments. The target function provided to ternary is then called
 *  with the first three values passed to the function returned. All other
 *  arguments that may be supplied are ignored, so the target function
 *  is effectively transformed into a ternary function.
 *
 *
 *  @param { function } target
 *
 *  The function to call with three arguments.
 *
 *
 *  @return { function }
 *
 *  A ternary function that calls target with its first three arguments.
 *
 *
 *
 */
export const ternary = curry(function ternary (target) {

  return curry(define(3, ternary.name + target.name, function (first, second, third) {
    return target.call(this, first, second, third);
  }));

});





/**
 *  @function truthy
 *
 *
 *  @summary
 *
 *  A function that always returns true.
 *
 *
 *  @description
 *
 *  Calling truthy always yields the primitive value true. All
 *  arguments passed to this function as well as the context it
 *  is initialized with are ignored. This is just a shorthand
 *  for situations where a function is expected and not the
 *  value itself.
 *
 *
 *  @return { boolean }
 *
 *  The boolean value true.
 *
 *
 *
 */
export function truthy () {
  return true;
}





/**
 *  @function unapply
 *
 *
 *  @summary
 *
 *  The inverse of the apply function.
 *
 *
 *  @description
 *
 *  The apply function takes a list of arguments and passes them
 *  one by one to another function. This function returns a function
 *  that takes a variadic number of arguments and puts them in an
 *  array, which is then passed to the target function provided.
 *  The number of arguments the returned function should expect can
 *  be specified through the optional second parameter, which
 *  defaults to one.
 *
 *
 *  @param { function } target
 *
 *  The function to call with an array of arguments.
 *
 *
 *  @param { number } [ length = 1 ]
 *
 *  The number of arguments to expect.
 *
 *
 *  @return { function }
 *
 *  A function calling target with a list of its arguments.
 *
 *
 *
 */
export const unapply = curry(function unapply (target, length = 1) {

  return curry(define(length, target.name, function () {
    return target.call(this, [...arguments]);
  }));

});





/**
 *  @function unary
 *
 *
 *  @summary
 *
 *  Converts a function of any arity into an unary function.
 *
 *
 *  @description
 *
 *  When called with a function, it returns another function that
 *  takes one argument. The target function provided to unary is then
 *  called with the first value passed to the function returned. All other
 *  arguments that may be supplied are ignored, so the target function
 *  is effectively transformed into an unary function.
 *
 *
 *  @param { function } target
 *
 *  The function to call with one argument.
 *
 *
 *  @return { function }
 *
 *  An unary function that calls target with its first argument.
 *
 *
 *
 */
export const unary = curry(function unary (target) {

  return curry(define(1, unary.name + target.name, function (value) {
    return target.call(this, value);
  }));

});





/**
 *  @function wrap
 *
 *
 *  @summary
 *
 *  Encloses one function with another.
 *
 *
 *  @description
 *
 *  This function takes two functions as arguments and returns another
 *  function. The first argument is a target function, the second argument
 *  is a wrapper function that encloses the first one. The function that’s
 *  returned from wrap takes the arguments for the target function and
 *  passes them together with a reference to this function to the
 *  specified wrapper.
 *
 *  The wrapper function acts as a man in the middle and can do some
 *  preprocessing before calling the target function, or decide, depending
 *  on the arguments provided, not to invoke the target function at all.
 *  Anyway the result of the function returned from wrap is the value
 *  that is returned from the wrapper.
 *
 *
 *  @param { function } target
 *
 *  The function to wrap.
 *
 *
 *  @param { function } wrapper
 *
 *  The wrapper function that encloses target.
 *
 *
 *  @return { function }
 *
 *  A function that calls the wrapper with target.
 *
 *
 *
 */
export const wrap = curry(function wrap (target, wrapper) {

  return curry(defineFrom(target, function () {
    return wrapper.call(this, target, ...arguments);
  }));

});
