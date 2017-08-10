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

import { when } from './logic.js';

import { array, callable } from './predicates.js';





/**
 *  @function entries
 *
 *
 *  @summary
 *
 *  Returns an array with the entries of an object.
 *
 *
 *  @description
 *
 *  This function expects to be called with an object and
 *  returns an array containing its entries. If the provided
 *  data structure has a method with the name entries, it is
 *  assumed that this method will return an iterator and it
 *  will be called to extract the entries.
 *
 *
 *  If no such method exists, then it is supposed that the
 *  value provided to entries is a plain object and the array
 *  that is returned will contain pairs of the keys and values
 *  of its enumerable own properties. If the argument cannot
 *  be coerced to an object, an exception will be thrown.
 *
 *
 *  @param { Object } data
 *
 *  The data structure whose entries should be extracted.
 *
 *
 *  @return { Array }
 *
 *  An array with the data structures entries.
 *
 *
 *
 */
export const entries = curry(function entries (data) {
  return callable(data.entries) ? [...data.entries()] : Object.entries(data);
});





/**
 *  @function flatten
 *
 *
 *  @summary
 *
 *  Builds a flat list from nested arrays.
 *
 *
 *  @description
 *
 *  This function takes an array and builds a new array from
 *  its elements. In the process nested arrays are destructured
 *  recursively and their elements are appended to the new list,
 *  depth first. So the order is preserved such that the array
 *  returned looks like the written out nested list without
 *  the inner brackets.
 *
 *
 *  @param { Array } list
 *
 *  A potentially nested list to flatten.
 *
 *
 *  @return { Array }
 *
 *  The flattened list.
 *
 *
 *
 */
export const flatten = curry(function flatten (list) {
  return list.reduce((result, value) => result.concat(when(array, flatten, value)), []);
});





/**
 *  @function head
 *
 *
 *  @summary
 *
 *  Returns the first item of a list.
 *
 *
 *  @description
 *
 *  This function expects to be called with a list and
 *  returns the lists first item, or undefined if the list
 *  is empty. The function is generic, so the argument does
 *  not have to be an array but can be any object that
 *  implements the Iterable interface.
 *
 *
 *  @param { Iterable } list
 *
 *  An array or other object that is iterable.
 *
 *
 *  @return { * }
 *
 *  The first item of the list.
 *
 *
 *
 */
export const head = curry(function head ([item]) {
  return item;
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
export const tail = curry(function tail ([head, ...remainder]) {
  return remainder;
});
