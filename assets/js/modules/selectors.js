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
