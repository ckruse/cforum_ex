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
 *  @function keys
 *
 *
 *  @summary
 *
 *  Returns an array with the keys of an object.
 *
 *
 *  @description
 *
 *  This function expects to be called with an object and
 *  returns an array containing its keys. If the object that
 *  keys has been called with has a method of the same name,
 *  it is assumed that this method will return an iterator
 *  and it will be called to extract the keys.
 *
 *
 *  If no such method exists, then it is supposed that the
 *  data structure provided to keys is a plain object and the
 *  array returned will contain the keys of its enumerable own
 *  properties. If the value passed to keys cannot be coerced
 *  to an object, an exception will be thrown.
 *
 *
 *  @param { Object } data
 *
 *  The data structure whose keys should be extracted.
 *
 *
 *  @return { Array }
 *
 *  An array with the data structures keys.
 *
 *
 *
 */
export const keys = curry(function keys (data) {
  return callable(data.keys) ? [...data.keys()] : Object.keys(data);
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
export const peak = curry(function peak ([...list]) {
  return list[list.length - 1];
});





/**
 *  @function reduce
 *
 *
 *  @summary
 *
 *  Reduces the items of a list to a single value.
 *
 *
 *  @description
 *
 *  This function reduces a list to a single value. It takes a
 *  callback function to iterate over the lists values as its first
 *  argument. The second argument is an accumulator value that is
 *  passed to the callback function in its first invokation. The
 *  third and last argument is an iterable object to process.
 *
 *
 *  The callback function will be invoked for each item that is
 *  derived from the iterable object with four arguments. The first
 *  argument is the accumulator. That is the value which is passed
 *  to reduce for the first call, in all subsequent calls this is
 *  the value that has been returned from the callback function.
 *
 *
 *  The second argument to the callback is the current value of
 *  of the list that is iterated over and the third argument is its
 *  index. The fourth and final argument that is passed to callback
 *  is the array that is built from the iterable object that the
 *  reduce function has been invoked with.
 *
 *
 *  @param { function } callback
 *
 *  The function to process the list items and the accumulator.
 *
 *
 *  @param { * } accumulator
 *
 *  The accumulator value.
 *
 *
 *  @param { Iterable } list
 *
 *  The list whose items are passed to callback.
 *
 *
 *  @return { * }
 *
 *  The accumulated value.
 *
 *
 *
 */
export const reduce = curry(function reduce (callback, accumulator, [...list]) {
  return list.reduce(callback, accumulator);
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





/**
 *  @function transform
 *
 *
 *  @summary
 *
 *  Creates a list of transformed values from another list.
 *
 *
 *  @description
 *
 *  This function takes a callback function and an iterable
 *  object and returns an array. It applies the callback to each
 *  item derived from the iterable object and appends the result
 *  to the array returned. The callback function is called with
 *  the current value, its index and a reference to the array
 *  built from the iterable objects items.
 *
 *
 *  @param { function } callback
 *
 *  A function to apply to each item of a list.
 *
 *
 *  @param { Iterable } list
 *
 *  A list to transform by the callback function.
 *
 *
 *  @return { Array }
 *
 *  The transformed list.
 *
 *
 *
 */
export const transform = curry(function transform (callback, [...list]) {
  return list.map(callback);
});





/**
 *  @function values
 *
 *
 *  @summary
 *
 *  Returns an array with the values of an object.
 *
 *
 *  @description
 *
 *  This function expects to be called with an object and
 *  returns an array containing its values. If the object that
 *  values has been called with has a method of the same name,
 *  it is assumed that this method will return an iterator
 *  and it will be called to extract the values.
 *
 *
 *  If no such method exists, then it is supposed that the
 *  data structure provided to values is a plain object and the
 *  array returned will contain the values of its enumerable own
 *  properties. If the value passed to values cannot be coerced
 *  to an object, an exception will be thrown.
 *
 *
 *  @param { Object } data
 *
 *  The data structure whose values should be extracted.
 *
 *
 *  @return { Array }
 *
 *  An array with the data structures values.
 *
 *
 *
 */
export const values = curry(function values (data) {
  return callable(data.values) ? [...data.values()] : Object.values(data);
});
