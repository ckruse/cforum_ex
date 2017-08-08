/**
 *  @module lists
 *
 *
 *  @summary
 *
 *  Provides functions for list processing.
 *
 *
 *
 */





import { curry } from './functional.js';





/**
 *  @function head
 *
 *
 *  @summary
 *
 *  Returns the first element of a list.
 *
 *
 *
 */
export const head = curry(function head ([first]) {
  return first;
});





/**
 *  @function peak
 *
 *
 *  @summary
 *
 *  Returns the last element of a list.
 *
 *
 *  @description
 *
 *
 *  @param { Array } list
 *
 *  An array or other indexed collection.
 *
 *
 *  @return { * }
 *
 *  The last item of the list.
 *
 *
 *
 */
export const peak = curry(function peak (list) {
  return list[list.length - 1];
});





/**
 *  @function tail
 *
 *
 *  @summary
 *
 *  Returns the remainder of a list.
 *
 *
 *  @description
 *
 *  The tail function takes an array and returns another array
 *  whose elements are those of the array provided without the first
 *  element. If the supplied array contains less than two elements,
 *  an empty array will be returned. The argument does not have to
 *  be an array, though. It can be any object that implements
 *  the Iterable interface.
 *
 *
 *  @param { Array } list
 *
 *  An array or other object that is iterable.
 *
 *
 *  @return { Array }
 *
 *  The remainder of the provided list.
 *
 *
 *
 */
export const tail = curry(function tail ([head, ...rest]) {
  return rest;
});
