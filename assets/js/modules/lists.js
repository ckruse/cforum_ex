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
 *  Returns all but the first element of a list.
 *
 *
 *
 */
export const tail = curry(function tail ([head, ...rest]) {
  return rest.length ? rest : [head];
});
