/**
 *  @module elements
 *
 *
 *  @summary
 *
 *  This module provides functions to work with elements.
 *
 *
 *  @requires functional
 *
 *  @requires logic
 *
 *
 *
 */





import { compose, curry } from './functional.js';

import { branch, not } from './logic.js';





/**
 *  @function children
 *
 *
 *  @summary
 *
 *  Returns a list with child elements.
 *
 *
 *  @description
 *
 *  Documents, DocumentFragments and elements implement the
 *  interface ParentNode of the DOM, which provides a property
 *  named children whose value is a HTMLCollection of elements
 *  that are children of the context object. This function is
 *  a wrapper for this property. It is called with a context
 *  object and returns its child elements in an array.
 *
 *
 *  @param { Document | DocumentFragment | Element } context
 *
 *  The object whose child elements should be returned.
 *
 *
 *  @return { Array }
 *
 *  The list of child elements.
 *
 *
 *
 */
export const children = curry(function children (context) {
  return Array.from(context.children);
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
export const create = curry(function create (tagName) {
  return document.createElement(tagName);
});





/**
 *  @function firstElementChild
 *
 *
 *  @summary
 *
 *  Returns the first element child of an object.
 *
 *
 *  @description
 *
 *  This is a functional wrapper for the firstElementChild
 *  property that is implemented by documents, DocumentFragments
 *  and elements. It returns the first child node of the context
 *  object that is an element or null, if the context object
 *  does not have any child nodes that are elements.
 *
 *
 *  @param { Document | DocumentFragment | Element } context
 *
 *  The object whose first element child should be returned.
 *
 *
 *  @return { ? Element }
 *
 *  The first element child or null.
 *
 *
 *
 */
export const firstElementChild = curry(function firstElementChild (context) {
  return context.firstElementChild;
});





/**
 *  @function firstElementSibling
 *
 *
 *
 */
export const firstElementSibling = curry(function firstElementSibling (element) {
  return compose(firstElementChild, parentElement, element);
});





/**
 *  @function focus
 *
 *
 *
 */
export const focus = curry(function focus (element) {
  return element.focus(), element;
});





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
 *  @summary
 *
 *  Returns the last element child of an object.
 *
 *
 *  @description
 *
 *  This is a functional wrapper for the lastElementChild
 *  property that is implemented by documents, DocumentFragments
 *  and elements. It returns the last child node of the context
 *  object that is an element or null, if the context object
 *  does not have any child nodes that are elements.
 *
 *
 *  @param { Document | DocumentFragment | Element } context
 *
 *  The object whose last element child should be returned.
 *
 *
 *  @return { ? Element }
 *
 *  The last element child or null.
 *
 *
 *
 */
export const lastElementChild = curry(function lastElementChild (context) {
  return context.lastElementChild;
});





/**
 *  @function lastElementSibling
 *
 *
 *
 */
export const lastElementSibling = curry(function lastElementSibling (element) {
  return compose(lastElementChild, parentElement, element);
});





/**
 *  @function nextElementSibling
 *
 *
 *  @summary
 *
 *  Returns the next element sibling.
 *
 *
 *  @description
 *
 *  This function takes an object that is either an element or
 *  that inherits from the CharacterData interface of the DOM and
 *  returns its next element sibling. If there is no next element
 *  sibling, the function returns null. This is a wrapper for
 *  the native property of the same name.
 *
 *
 *  @param { CharacterData | Element } context
 *
 *  The node whose next element sibling should be returned.
 *
 *
 *  @return { ? Element }
 *
 *  The next element sibling or null.
 *
 *
 *
 */
export const nextElementSibling = curry(function nextElementSibling (context) {
  return context.nextElementSibling;
});





/**
 *  @function parentElement
 *
 *
 *  @summary
 *
 *  Returns the parent element of a node.
 *
 *
 *  @description
 *
 *  This is a wrapper for the native parentElement property
 *  which all DOM nodes implement. It returns the parent element
 *  of the context object that the function has been called with.
 *  In case this object does not have a parent element the value
 *  null is returned.
 *
 *
 *  @param { Node } context
 *
 *  The object whose parent element should be returned.
 *
 *
 *  @return { ? Element }
 *
 *  Either the nodes parent element or null.
 *
 *
 *
 */
export const parentElement = curry(function parentElement (context) {
  return context.parentElement;
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
 *  @function previousElementSibling
 *
 *
 *  @summary
 *
 *  Returns the previous element sibling.
 *
 *
 *  @description
 *
 *  This function takes an object that is either an element or
 *  that inherits from the CharacterData interface of the DOM and
 *  returns its previous element sibling. If there is no previous
 *  element sibling, the function returns null. This is a wrapper
 *  for the native property of the same name.
 *
 *
 *  @param { CharacterData | Element } context
 *
 *  The node whose previous element sibling should be returned.
 *
 *
 *  @return { ? Element }
 *
 *  The previous element sibling or null.
 *
 *
 *
 */
export const previousElementSibling = curry(function previousElementSibling (context) {
  return context.previousElementSibling;
});





/**
 *  @function removeAttribute
 *
 *
 *
 */
export const removeAttribute = curry(function removeAttribute (name, element) {
  return element.removeAttribute(name), element;
});





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
 *  @function elementSiblings
 *
 *
 *
 *
 */
export const elementSiblings = curry(function elementSiblings (element) {
  return compose(children, parentElement, element);
});





/**
 *  @function toggleHiddenState
 *
 *
 *
 */
export const toggleHiddenState = curry(function toggleHiddenState (element) {
  return element.hidden = not(element.hidden), element;
});





/**
 *  @function toggleTabIndex
 *
 *
 *
 */
export const toggleTabIndex = curry(function toggleTabIndex (element) {
  return element.tabIndex = element.tabIndex ? 0 : -1, element;
});
