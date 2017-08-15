/**
 *  @module elements
 *
 *
 *  @requires functional
 *
 *
 *
 */





import { curry } from './functional.js';





/**
 *  @function children
 *
 *
 *  @summary
 *
 *  Returns a list with child elements.
 *
 *
 *
 */
export const children = curry(function children (element) {
  return Array.from(element.children);
});
