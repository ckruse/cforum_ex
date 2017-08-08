/**
 *  @module predicates
 *
 *
 *  @summary
 *
 *  Provides predicate functions.
 *
 *
 *  @requires functional
 *
 *
 *
 */





import { curry } from './functional.js';





/**
 *  @function array
 *
 *
 *  @summary
 *
 *  Tests if a value is an array.
 *
 *
 *  @description
 *
 *  This is useful when working with the Document Object Model, where
 *  some methods return indexed collections that are not real arrays. That
 *  means, apart from being iterable and possibly providing a forEach method,
 *  these collections lack the capabilities offered by native arrays. So if
 *  it’s not clear that a value is an array and if it matters, this
 *  function can be used for testing.
 *
 *
 *  @param { * } value
 *
 *  The value to test.
 *
 *
 *  @return { Boolean }
 *
 *  A boolean indicating if the the value is an array or not.
 *
 *
 *
 */
export const array = curry(function array (value) {
  return Array.isArray(value);
});





/**
 *  @function callable
 *
 *
 *
 *
 */
export const callable = curry(function callable (value) {
  return typeof value === 'function';
});





/**
 *  @function defined
 *
 *
 *  @summary
 *
 *  Tests if a value is neither null nor undefined.
 *
 *
 *  @description
 *
 *  Unlike other values null and undefined are not coerced to objects
 *  in contexts where an object is expected, and a member expression that
 *  references one of these values causes an exception to be thrown. In
 *  these cases as well as in many other situations it is good advice to
 *  test against these values before doing stuff. That’s the purpose
 *  of this function.
 *
 *
 *  @param { * } value
 *
 *  The value to test.
 *
 *
 *  @returns { Boolean }
 *
 *  The result of the test.
 *
 *
 *
 */
export const defined = curry(function defined (value) {
  return value != null;
});





/**
 *  @function equal
 *
 *
 *  @summary
 *
 *  Tests two values for equality.
 *
 *
 *  @description
 *
 *  This function takes to operands and checks if they’re the same
 *  value. The test is not performed by the strict equality algorithm,
 *  so positive and negative zero are not considered to be the same.
 *  Additionally, two values which are both NaN will be recognized
 *  as the same value. The other results are identical with those of
 *  the strict equality algorithm, so there are no implicit type
 *  conversions to take care of.
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
 *  @returns { Boolean }
 *
 *  The result of the test.
 *
 *
 *
 */
export const equal = curry(function equal (first, second) {
  return Object.is(first, second);
});





/**
 *  @function greaterThan
 *
 *
 *  @summary
 *
 *  Tests if a value is greater than another.
 *
 *
 *  @description
 *
 *  This is merely a wrapper for the native greater than operator and
 *  therefore, the operands might be subject to implicit type conversion.
 *  Except for strings, all other values will be coerced to the number
 *  type, so this test will seldomly make sense for operands that are
 *  not of the number or string data type.
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
 *  @returns { Boolean }
 *
 *  True if the first operand is greater than the second, else false.
 *
 *
 *
 */
export const greaterThan = curry(function greaterThan (first, second) {
  return first > second;
});





/**
 *  @function greaterThanOrEqual
 *
 *
 *  @summary
 *
 *  Tests if a value is greater than or equal to another.
 *
 *
 *  @description
 *
 *  This function uses the native greater than or equal operator, so
 *  the operands might be subject to implicit type conversion. For example
 *  an empty string and the numerical value zero will be considered equal.
 *  In addition, and other than the equal function defined in this module,
 *  this function will not assert equality if both operands are NaN.
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
 *  @return { boolean }
 *
 *  The result of the comparsion.
 *
 *
 *
 */
export const greaterThanOrEqual = curry(function greaterThanOrEqual (first, second) {
  return first >= second;
});





/**
 *  @function lessThan
 *
 *
 *  @summary
 *
 *  Tests if one value is smaller than another.
 *
 *
 *  @description
 *
 *  This is merely a wrapper for the native less than operator and
 *  therefore, the operands might be subject to implicit type conversion.
 *  Except for strings, all other values will be coerced to the number
 *  type, so this test will seldomly make sense for operands that are
 *  not of the number or string data type.
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
 *  @returns { Boolean }
 *
 *  True if the first operand is less than the second, else false.
 *
 *
 *
 */
export const lessThan = curry(function lessThan (first, second) {
  return first < second;
});





/**
 *  @function lessThanOrEqual
 *
 *
 *  @summary
 *
 *  Tests if a value is less than or equal to another.
 *
 *
 *  @description
 *
 *  This function uses the native less than or equal operator, so the
 *  operands might be subject to implicit type conversion. For example
 *  an empty string and the numerical value zero will be considered equal.
 *  In addition, and other than the equal function defined in this module,
 *  this function will not assert equality if both operands are NaN.
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
 *  @return { boolean }
 *
 *  The result of the comparsion.
 *
 *
 *
 */
export const lessThanOrEqual = curry(function lessThanOrEqual (first, second) {
  return first <= second;
});





/**
 *  @function string
 *
 *
 *
 */
export const string = curry(function string (value) {
  return typeof value === 'string';
});
