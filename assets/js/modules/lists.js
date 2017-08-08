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
 *  The peak function takes a list and returns the last item
 *  within. The function is generic, so the argument does not have
 *  to be an array or another indexed collection like a string or
 *  arguments object. Any object that implements the Iterable
 *  interface will do fine. In case an empty list has been
 *  provided, the return value will be undefined.
 *
 *
 *  @param { Iterable } list
 *
 *  An array or other object that is iterable.
 *
 *
 *  @return { * }
 *
 *  The last item of the list.
 *
 *
 *
 */
export const peak = curry(function peak ([...items]) {
  return items[items.length - 1];
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
 *  The tail function takes a list and returns an array whose
 *  elements are the items of the provided list except the first
 *  one. If the supplied list contains less than two items, then
 *  an empty array will be returned. The list does not have to
 *  be an array, it can be any object that implements the
 *  Iterable interface.
 *
 *
 *  @param { Iterable } list
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
