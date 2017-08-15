/**
 *  @module selectors
 *
 *
 *
 *
 */





/**
 *  @function all
 *
 *
 *  @summary
 *
 *  Returns all elements a selector matches.
 *
 *
 *  @description
 *
 *  The function all takes a selector string and optionally a context
 *  object and always returns an array. It searches the subtree of the
 *  context object, which defaults to the document object, using the
 *  provided selector. If any elements match the selector, they are
 *  returned, else an empty array is returned. If the first argument
 *  is not a valid CSS selector, this produces an error.
 *
 *
 *  @param { string } selector
 *
 *  The selector to use.
 *
 *
 *  @param { Document | DocumentFragment | Element } [ context = document ]
 *
 *  Context object whose subtree to search.
 *
 *
 *  @return { Array }
 *
 *  An array that is either empty or contains the matching elements.
 *
 *
 *
 */
export function all (selector, context = document) {
  return Array.from(context.querySelectorAll(selector));
}





/**
 *  @function classes
 *
 *
 *  @summary
 *
 *  Selects elements by their class attribute.
 *
 *
 *  @description
 *
 *  This function searches the DOM for elements that have
 *  the same classes as specified by the string passed in as the
 *  first argument. The search can be restricted to a subtree by
 *  passing in an element as the second argument. If multiple
 *  classes should be taken into account, their names are
 *  separated by whitespace.
 *
 *
 *  @param { string } selector
 *
 *  Class names separated by whitespace.
 *
 *
 *  @param { Document | Element } [ context = document ]
 *
 *  The object whose subtree to search.
 *
 *
 *  @return { Array }
 *
 *  An array containing the elements found, if any.
 *
 *
 *
 */
export function classes (selector, context = document) {
  return Array.from(context.getElementsByClassName(selector));
}





/**
 *  @function id
 *
 *
 *  @summary
 *
 *  Retrieves an element by the value of its ID attribute.
 *
 *
 *  @description
 *
 *  This is just a wrapper for the native getElementById method. If
 *  there is no need for a more complex selector or the tree to search
 *  is not restricted to an element deeper in the hierarchy of the dom,
 *  then it is better to use this function rather than the select
 *  function that is also exported from this module.
 *
 *
 *  @param { string } name
 *
 *  The ID of the element to fetch.
 *
 *
 *  @param { Document | DocumentFragment } [ context = document ]
 *
 *  The context object whose subtree to search.
 *
 *
 *  @return { ? Element }
 *
 *  The element with the given ID or null.
 *
 *
 *
 */
export function id (name, context = document) {
  return context.getElementById(name);
}





/**
 *  @function select
 *
 *
 *  @summary
 *
 *  Returns the first element a selector matches.
 *
 *
 *  @description
 *
 *  This is merely a wrapper for the native querySelector method.
 *  It takes a selector string and optionally a context object which
 *  defaults to the document object. The subtree of the context object
 *  is searched using the selector and the first element that matches
 *  will be returned, or if no element matches, the value null. If
 *  the provided string is not a valid CSS selector, a syntax
 *  error will be thrown.
 *
 *
 *  @param { string } selector
 *
 *  The selector to use.
 *
 *
 *  @param { Document | DocumentFragment | Element } [ context = document ]
 *
 *  Context object whose subtree to search.
 *
 *
 *  @return { ? Element }
 *
 *  Either a matching element or the primitive value null.
 *
 *
 *
 */
export function select (selector, context = document) {
  return context.querySelector(selector);
}





/**
 *  @function tags
 *
 *
 *  @summary
 *
 *  Selects elements by their tag name.
 *
 *
 *  @description
 *
 *  This function searches the DOM for elements that have
 *  the same tag as specified by the string passed in as the
 *  first argument. The search can be restricted to a subtree by
 *  passing in an element as the second argument. The default
 *  context is the document object. Just as the classes function
 *  the function tags returns an array instead of a live
 *  collection.
 *
 *
 *  @param { string } selector
 *
 *  The tag name to search for.
 *
 *
 *  @param { Document | Element } [ context = document ]
 *
 *  The object whose subtree to search.
 *
 *
 *  @return { Array }
 *
 *  An array containing the elements found, if any.
 *
 *
 *
 */
export function tags (selector, context = document) {
  return Array.from(context.getElementsByTagName(selector));
}
