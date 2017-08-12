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
 *  @requires lists
 *
 *  @requires logic
 *
 *  @requires predicates
 *
 *
 *
 */





import { curry, pipe } from './functional.js';

import { entries, flatten, from } from './lists.js';

import { branch } from './logic.js';

import { equal, object, string } from './predicates.js';





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
 *  @function bind
 *
 *
 *  @summary
 *
 *  Connects an object with multiple actions.
 *
 *
 *  @description
 *
 *  This function can be used to register an arbitrary number
 *  of event handlers for any types of events. It expects to be
 *  called with a context object that is supposed to be the event
 *  target and a data structure, containing strings specifying the
 *  event types and the associated handler functions which should
 *  be invoked when a corresponding event reaches the target.
 *
 *
 *  The bind function can be called with a dictionary as its
 *  second argument, that is just a plain object. In this case
 *  the keys of the enumerable own properties of the object will
 *  be used to determine the type of the event. The property value
 *  can either be a reference to a handler function or an array of
 *  functions. In the latter case all functions contained in the
 *  array will be registered for the event type that is derived
 *  from the property key.
 *
 *
 *  Since property names of objects must be unique, defining
 *  multiple properties declaring the same event type as key is
 *  no option. This should always be kept in mind, especially in
 *  the case that several dictionaries are supposed to be merged,
 *  aiming to combine different predefined behaviors. This will
 *  likely lead to a situation where properties of one object
 *  are overwritten by properties of another.
 *
 *
 *  However, to also account for more sophisticated use cases,
 *  this function provides alternative means to the caller, in that
 *  it is possible to invoke bind with an iterable object instead of
 *  a dictionary. So, event types and functions can be delivered in
 *  an array, a map, a set or any other data structure implementing
 *  the Iterable interface. The only convention one has to respect
 *  is that one or more handler functions always follow the
 *  string designating the type of the event.
 *
 *
 *  @todo
 *
 *  Replace the call to forEach with something better. Since the
 *  function on returns the context object anyway, reducing the list
 *  of actions would enable a more purposeful solution. However, the
 *  reducer should be created programmatically and we do not have
 *  the necessary abstractions yet.
 *
 *
 *
 *  @param { EventTarget } context
 *
 *  The object to attach event handlers to.
 *
 *
 *  @param { Iterable | Object } actions
 *
 *  List containing event types and handlers.
 *
 *
 *  @return { EventTarget }
 *
 *  The context object.
 *
 *
 *
 */
export const bind = curry(function bind (context, actions) {
  const list = pipe(branch(object, entries, from), flatten)(actions);

  let action;
  list.forEach(branch(string, event => action = on(context, event), handler => action(handler)));

  return context;
});





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
 *  Sets the hidden attribute of an element.
 *
 *
 *
 *
 */
export const hide = curry(function hide (element) {
  element.setAttribute('hidden', 'hidden')
  return element;
});





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
 *  @function key
 *
 *
 *  @summary
 *
 *  Predicate to determine if a key was pressed.
 *
 *
 *
 */
export const key = curry(function key (event, name) {
  return equal(event.key, name);
});





/**
 *  @function on
 *
 *
 *  @summary
 *
 *  Registers an event handler for an object.
 *
 *
 *  @description
 *
 *  This is mostly a shorthand for the native addEventListener method,
 *  so it takes an object that implements the EventTarget interface, a
 *  string for the event type and a callback function that is invoked in
 *  case the dispatched event reaches the context object. An optional
 *  fourth argument can be used to specify parameters for the event
 *  listener, it defaults to false. The value returned is the
 *  object the handler has been registered for.
 *
 *
 *  @param { EventTarget } context
 *
 *  The object on which the event should be observed.
 *
 *
 *  @param { string } type
 *
 *  The type of the event.
 *
 *
 *  @param { function } callback
 *
 *  The function that should handle the event.
 *
 *
 *  @param { boolean | Object } [ options = false ]
 *
 *  A boolean to control capturing or an options object.
 *
 *
 *  @return { EventTarget }
 *
 *  The context object.
 *
 *
 *
 */
export const on = curry(function (context, type, callback, options = false) {
  context.addEventListener(type, callback, options);
  return context;
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
 *  @function preventDefault
 *
 *
 *  @summary
 *
 *  Prevents a default action.
 *
 *
 *  @description
 *
 *  This is just a wrapper for the preventDefault method that
 *  event objects implement. When called, an associated default
 *  action will be stopped. This function can be used as a plug
 *  when performing function composition, because the event
 *  that has been passed in as an argument is also the
 *  return value of the function.
 *
 *
 *  @param { Event } event
 *
 *  An event whose default action to prevent.
 *
 *
 *  @return { Event }
 *
 *  The provided event object.
 *
 *
 *
 */
export function preventDefault (event) {
  event.preventDefault();
  return event;
}





/**
 *  @function ready
 *
 *
 *  @summary
 *
 *  Executes code when the DOM is loaded and parsed.
 *
 *
 *  @description
 *
 *  This function registers an event listener to be called when
 *  the DOM of the page is fully loaded and parsed. The function
 *  does not return any value. Since the DOMContentLoaded event
 *  is used, external ressources might not be available at the
 *  time the callback is invoked.
 *
 *
 *  @param { function } callback
 *
 *  The function to execute.
 *
 *
 *
 */
export function ready (callback) {
  window.addEventListener('DOMContentLoaded', callback);
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
