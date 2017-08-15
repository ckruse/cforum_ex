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





/**
 *  @function firstElementChild
 *
 *
 *
 */
export function firstElementChild (element) {
  return element.firstElementChild;
}





/**
 *  @function focus
 *
 *
 *
 */
export function focus (element) {
  element.focus();
  return element;
}





/**
 *  @function getAttribute
 *
 *
 *
 */
export const getAttribute = curry(function getAttribute (name, element) {
  return element.getAttribute(name);
});





/**
 *  @function hasAttribute
 *
 *
 *
 */
export const hasAttribute = curry(function hasAttribute (name, element) {
  return element.hasAttribute(name);
});





/**
 *  @function lastElementChild
 *
 *
 *
 */
export function lastElementChild (element) {
  return element.lastElementChild;
}





/**
 *  @function nextElementSibling
 *
 *
 *
 */
export function nextElementSibling (element) {
  return element.nextElementSibling;
}





/**
 *  @function parentElement
 *
 *
 *
 */
export function parentElement (element) {
  return element.parentElement;
}





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
 *  @function previousElementSibling
 *
 *
 *
 */
export function previousElementSibling (element) {
  return element.previousElementSibling;
}





/**
 *  @function setAttribute
 *
 *
 *
 *
 */
export const setAttribute = curry(function setAttribute (name, value, element) {
  return element.setAttribute(name, value), element;
});





/**
 *  @function toggleHiddenState
 *
 *
 *
 */
export function toggleHiddenState (element) {
  element.hasAttribute('hidden') ? element.removeAttribute('hidden') : element.setAttribute('hidden', 'hidden');
  return element;
}





/**
 *  @function toggleTabIndex
 *
 *
 *
 */
export function toggleTabIndex (element) {
  element.tabIndex = element.tabIndex ? 0 : -1;
  return element;
}
