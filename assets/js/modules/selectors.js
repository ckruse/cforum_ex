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
