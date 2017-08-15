/**
 *  @module events
 *
 *
 *  @summary
 *
 *  Provides functions for event handling.
 *
 *
 *
 */





import { curry, pipe } from './functional.js';

import { entries, flatten, from } from './lists.js';

import { branch } from './logic.js';

import { equal, object, string } from './predicates.js';





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
export const key = curry(function key (name, event) {
  return equal(name, event.key);
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





/**
 *  @function target
 *
 *
 *
 */
export function target (event) {
  return event.target;
}
