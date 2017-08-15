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
