/**
 *  @module dom
 *
 *
 *  @summary
 *
 *  Provides helpers for handling the DOM.
 *
 *
 *  @requires functional
 *
 *  @requires predicates
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





/**
 *  @function hide
 *
 *
 *  @summary
 *
 *  Sets the hidden attribute of an element.
 *
 *
 *
 *
 */
export const hide = curry(function hide (element) {
  element.setAttribute('hidden', 'hidden');
  return element;
});





/**
 *  @function parse
 *
 *
 *  @summary
 *
 *  Parses a string with markup into a DocumentFragment.
 *
 *
 *  @description
 *
 *  This function expects a string of HTML code. It parses the
 *  markup into DOM nodes and attaches them to a DocumentFragment
 *  which is then returned. The fragment can be inserted into the
 *  DOM of the page like any other node and in this process, it
 *  is replaced by its content.
 *
 *
 *  @param { string } markup
 *
 *  The HTML code to parse.
 *
 *
 *  @return { DocumentFragment }
 *
 *  A DocumentFragment whose content is the parsed markup.
 *
 *
 *
 */
export function parse (markup) {
  const fragment = document.createDocumentFragment();

  fragment.innerHTML = markup;
  return fragment;
}





/**
 *  @function show
 *
 *
 *  @summary
 *
 *  Removes the hidden attribute from an element.
 *
 *
 *
 *
 */
export const show = curry(function show (element) {
  element.removeAttribute('hidden');
  return element;
})





/**
 *  @function stopPropagation
 *
 *
 *  @summary
 *
 *  Prevents an event from further propagation.
 *
 *
 *  @description
 *
 *  This is a functional wrapper for the stopPropagation method
 *  that’s implemented by event objects. When this function is called
 *  it only invokes said method and then returns the event object. The
 *  call to stopPropagation prevents the event from invoking handler
 *  functions that are registered for other objects than that whose
 *  handler received the event object. This function is useful
 *  when performing function composition.
 *
 *
 *  @param { Event } event
 *
 *  An event to intercept.
 *
 *
 *  @return { Event }
 *
 *  The event object.
 *
 *
 *
 */
export function stopPropagation (event) {
  event.stopPropagation();
  return event;
}
