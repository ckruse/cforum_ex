/**
 *  @module math
 *
 *
 *  @summary
 *
 *  Provides mathematical functions.
 *
 *
 *
 */

/**
 *  @function max
 *
 *
 *  @summary
 *
 *  Finds the maximum of the provided values.
 *
 *
 *  @description
 *
 *  This is a variadic function that returns the largest of the
 *  numbers it has been called with. Technically there is no need
 *  to supply only values of the number data type, as inapropriate
 *  types will be coerced to number if possible. Anyway, calling
 *  max with other data types is discouraged. If one of the values
 *  cannot be converted, the function will return NaN.
 *
 *
 *  @param { ...number } values
 *
 *  An arbitrary number of values to compare.
 *
 *
 *  @return { number }
 *
 *  The maximum of the compared values.
 *
 *
 *
 */
export function max(...values) {
  return Math.max.apply(null, values);
}

/**
 *  @function min
 *
 *
 *  @summary
 *
 *  Finds the minimum of the provided values.
 *
 *
 *  @description
 *
 *  This is a variadic function that returns the smallest of the
 *  numbers it has been called with. Technically there is no need
 *  to supply only values of the number data type, as inapropriate
 *  types will be coerced to number if possible. Anyway, calling
 *  min with other data types is discouraged. If one of the values
 *  cannot be converted, the function will return NaN.
 *
 *
 *  @param { ...number } values
 *
 *  An arbitrary number of values to compare.
 *
 *
 *  @return { number }
 *
 *  The minimum of the compared values.
 *
 *
 *
 */
export function min(...values) {
  return Math.min.apply(null, values);
}
