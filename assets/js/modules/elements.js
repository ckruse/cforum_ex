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
 *  @requires lists
 *
 *  @requires logic
 *
 *  @requires predicates
 *
 *
 *
 */





import { compose, curry, nothing } from './functional.js';

import { filter } from './lists.js';

import { branch, complement, not, when } from './logic.js';

import { equal } from './predicates.js';





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
 *  @param { Document | DocumentFragment | Element } parent
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
export const children = parent => Array.from(parent.children);





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
 *  @param { string } type
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
export const create = type => document.createElement(type);





/**
 *  @function elementSiblings
 *
 *
 *
 *
 */
export function elementSiblings (sibling) {
  return filter(complement(equal(sibling)), children(parentElement(sibling)));
}





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
 *  @param { Document | DocumentFragment | Element } parent
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
export const firstElementChild = parent => parent.firstElementChild;





/**
 *  @function firstElementSibling
 *
 *
 *
 */
export function firstElementSibling (sibling) {
  return when(equal(sibling), nothing, compose(firstElementChild, parentElement, sibling));
}





/**
 *  @function focus
 *
 *
 *  @summary
 *
 *  Sets focus on an element.
 *
 *
 *  @description
 *
 *  This function takes an element and returns that same
 *  element. It internally calls the native focus method of
 *  the provided element. If the element is focusable, as it
 *  is the case for interactive elements, then the element
 *  will receive focus. Otherwise nothing will happen.
 *
 *
 *  @param { HTMLElement }
 *
 *  An interactive element to set focus on.
 *
 *
 *  @return { HTMLElement }
 *
 *  The element after receiving focus.
 *
 *
 *
 */
export const focus = element => (element.focus(), element);





/**
 *  @function getAttribute
 *
 *
 *  @summary
 *
 *  Returns the value of an elements attribute.
 *
 *
 *  @description
 *
 *  This function expects to be called with a string specifying
 *  the name of an attribute and with an element object. It returns
 *  the value of the elements attribute with the given name. If the
 *  element does not have an attribute whose name matches the string
 *  that was passed to the function, null shall be returned.
 *
 *
 *  However, because this function is merely a wrapper for the
 *  native method of the same name, the value returned depends on
 *  the browsers implementation of the DOM standard, which sometime
 *  stated, that an empty string should be returned when the element
 *  does not have the specified attribute. So, it is possible that
 *  some browsers won’t return null in this case, as defined by
 *  the current standard.
 *
 *
 *  @param { string } name
 *
 *  The name of the attribute.
 *
 *
 *  @param { Element } element
 *
 *  The element whose attributes value shall be returned.
 *
 *
 *  @return { ? string }
 *
 *  The attributes value or null.
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
 *  @summary
 *
 *  A predicate to test if an element has an attribute.
 *
 *
 *  @description
 *
 *  This function is a wrapper for the native hasAttribute
 *  method which is implemented by elements. It takes a string
 *  specifying the name of an attribute and an element object.
 *  If the element has an attribute whose name matches the
 *  provided string true is returned, otherwise false.
 *
 *
 *  @param { string } name
 *
 *  The name of the attribute.
 *
 *
 *  @param { Element } element
 *
 *  The element on which search the attribute.
 *
 *
 *  @return { boolean }
 *
 *  The result of the test.
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
 *  @param { Document | DocumentFragment | Element } parent
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
export const lastElementChild = parent => parent.lastElementChild;





/**
 *  @function lastElementSibling
 *
 *
 *
 */
export function lastElementSibling (sibling) {
  return when(equal(sibling), nothing, compose(lastElementChild, parentElement, sibling));
}





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
 *  @param { CharacterData | Element } sibling
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
export const nextElementSibling = sibling => sibling.nextElementSibling;





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
 *  @param { Node } child
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
export const parentElement = child => child.parentElement;





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
 *  @param { CharacterData | Element } sibling
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
export const previousElementSibling = sibling => sibling.previousElementSibling;





/**
 *  @function removeAttribute
 *
 *
 *  @summary
 *
 *  Removes an attribute from an element.
 *
 *
 *  @description
 *
 *  This is a wrapper for the native removeAttribute method
 *  implemented by elements. It takes a string for the attributes
 *  name and an element object. It removes the attribute with the
 *  specified name from the element and returns the element after
 *  that. The attempt to remove an attribute that does not exist
 *  on the element will not raise an exception.
 *
 *
 *  @param { string } name
 *
 *  The name of the attribute that shall be removed.
 *
 *
 *  @param { Element } element
 *
 *  The element from which the attribute shall be removed.
 *
 *
 *  @return { Element }
 *
 *  The modified element.
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
 *  @summary
 *
 *  Sets an attribute of an element to a value.
 *
 *
 *  @description
 *
 *  This function is a wrapper for the native setAttribute
 *  method implemented by elements. It takes two strings for the
 *  name and value of an attribute and an element object. It sets
 *  the attribute with the given name to the given value on the
 *  supplied element. If the attribute already existed, its value
 *  is updated, else the attribute will be added to the element.
 *  The function returns the element it has been called with.
 *
 *
 *  @param { string } name
 *
 *  The name of the attribute.
 *
 *
 *  @param { string } value
 *
 *  The attributes value.
 *
 *
 *  @param { Element } element
 *
 *  The element to set the attribute on.
 *
 *
 *  @return { Element }
 *
 *  The modified element.
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
 *  @summary
 *
 *  Toggles the hidden attribute of an element.
 *
 *
 *  @description
 *
 *  The HTML hidden attribute is used to mark an element as not
 *  yet, or no longer relevant to the documents current state, or
 *  to indicate that the element should not be directly accessed by
 *  the user for other reasons. A hidden element will neither be
 *  displayed per default, nor will it be exposed to assistive
 *  software, like screen readers.
 *
 *
 *  This function takes an element and sets its hidden attribute
 *  if it is not currently set. Else it removes the attribute from
 *  the element. The element the function has been called with is
 *  returned after adding or removing the attribute. The function
 *  will not work for older browsers, though, since changing the
 *  property of an element is not reflected to the elements
 *  attributes if the attribute is not supported.
 *
 *
 *  @param { HTMLElement } element
 *
 *  The element whose hidden attribute should be toggled.
 *
 *
 *  @return { HTMLElement }
 *
 *  The provided element.
 *
 *
 *
 */
export function toggleHiddenState (element) {
  return element.hidden = not(element.hidden), element;
}





/**
 *  @function toggleTabIndex
 *
 *
 *  @summary
 *
 *  Adds an element to or removes it from taborder.
 *
 *
 *  @description
 *
 *  The tabindex attribute should only be used to make ordinary
 *  elements interactive content or to remove such elements from
 *  taborder. If this function is called with an element whose tabindex
 *  value is zero, meaning that it is focusable and in taborder, then
 *  the tabindex value will be set to minus one, such that the element
 *  is removed from the sequential keyboard navigation, but remains
 *  focusable. Otherwise the value is set from minus one to zero.
 *
 *
 *  @param { HTMLElement } element
 *
 *  The element whose tabindex attribute should be toggled.
 *
 *
 *  @return { HTMLElement }
 *
 *  The provided element.
 *
 *
 *
 */
export function toggleTabIndex (element) {
  element.tabIndex = not(equal(0, element.tabIndex)) ? 0 : -1;
  return element;
}
