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





/**
 *  @function create
 *
 *
 *  @summary
 *
 *  Creates an element.
 *
 *
 *  @description
 *
 *  This is a shorthand for the native createElement method,
 *  so it takes a string with a valid element name and returns
 *  an element of the specified type, or if the type has not
 *  been recognized, an unknown element. If it should become
 *  necessary, a future implementation might add support
 *  for an optional parameter for custom elements.
 *
 *
 *  @param { string } tagName
 *
 *  The type of element to create.
 *
 *
 *  @return { Element }
 *
 *  The element created.
 *
 *
 *
 */
export function create (tagName) {
  return document.createElement(tagName);
}
