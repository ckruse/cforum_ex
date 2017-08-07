/**
 *  @module confirmation
 *
 *
 *  @summary
 *
 *  Implements confirmation behavior for elements.
 *
 *
 *  @requires dom
 *
 *  @requires functional
 *
 *  @requires logic
 *
 *
 *
 */





import { all, bind, preventDefault, ready, stopPropagation } from './dom.js';

import { pipe } from './functional.js';

import { branch } from './logic.js';





/**
 *  @function addConfirmationBehavior
 *
 *
 *  @summary
 *
 *  Adds confirmation functionality to an element.
 *
 *
 *  @description
 *
 *  This function takes an element and adds an additional state
 *  for confirmation. That means, if the element is clicked in its
 *  default state, the click event is intercepted and the text of the
 *  element is changed as to ask for confirmation. Another activation
 *  will then pass and can be processed by other event handlers.
 *
 *
 *  After confirmation the default state is restored. This is
 *  also the case when the element loses focus before confirmation.
 *  To make these changes accessible, this function also manages the
 *  aria-live attribute of the element, that controls which changes
 *  should be provided to users of assistive software. The
 *  function does not have a return value.
 *
 *
 *  @param { Element } element
 *
 *  An element to process.
 *
 *
 *
 */
function addConfirmationBehavior (element) {
  element.text = element.textContent;
  bind(element, [

    ['blur', branch(
      confirming,
      pipe(disableConfirmationState, muteLiveRegion),
      muteLiveRegion
    )],

    ['click', branch(
      confirming,
      pipe(disableConfirmationState, muteLiveRegion),
      pipe(stopPropagation, preventDefault, enableConfirmationState)
    )],

    ['focus', makeLiveRegionAssertive]

  ]);
}





/**
 *  @function confirming
 *
 *
 *  @summary
 *
 *  A predicate checking if an event target has the class confirming.
 *
 *
 *  @description
 *
 *  This function expects an event object and returns a boolean value. It
 *  tests if the element that is the current target of the event object has
 *  the class confirming, indicating that the element is in the state of
 *  confirmation. If it is, than true is returned, otherwise false.
 *
 *
 *  @param { Event } event
 *
 *  Event whose current target to test.
 *
 *
 *  @return { boolean }
 *
 *  The result of the test.
 *
 *
 *
 */
function confirming (event) {
  return event.currentTarget.classList.contains('confirming');
}





/**
 *  @function enableConfirmationState
 *
 *
 *  @summary
 *
 *  Changes the elements state to confirming.
 *
 *
 *  @description
 *
 *  This function takes an event object and changes the state of
 *  the element that is the events current target to confirming, by
 *  adding a class of the same name and replacing the textual content
 *  with the text that is the value of the data-confirm attribute of
 *  the element. After the transformation the event object is
 *  returned for further processing.
 *
 *
 *  @param { Event } event
 *
 *  An event the action is connected to.
 *
 *
 *  @return { Event }
 *
 *  The provided event object.
 *
 *
 *
 */
function enableConfirmationState (event) {
  const element = event.currentTarget;
  element.classList.add('confirming'), element.textContent = element.dataset.confirm;
  return event;
}





/**
 *  @function disableConfirmationState
 *
 *
 *  @summary
 *
 *  Changes the elements state back to default.
 *
 *
 *  @description
 *
 *  This function takes an event object and changes the state of
 *  the element that is the events current target back to default.
 *  That means, it removes the confirming class from the element
 *  and restores the original text content. When work is done,
 *  the event object is returned.
 *
 *
 *  @param { Event } event
 *
 *  An event the action is connected to.
 *
 *
 *  @return { Event }
 *
 *  The provided event object.
 *
 *
 *
 */
function disableConfirmationState (event) {
  const element = event.currentTarget;
  element.classList.remove('confirming'), element.textContent = element.text;
  return event;
}





/**
 *  @function makeLiveRegionAssertive
 *
 *
 *  @summary
 *
 *  Changes the value of the aria-live attribute to assertive.
 *
 *
 *  @description
 *
 *  To make assistive software recognize the state change of the
 *  element from default to confirming, one has to make the element
 *  part of a so called live region, which is done by setting the
 *  aria-live attribute of the element. Because the confirmation
 *  message should be transmitted immediately to the user the
 *  value of the attribute is set to assertive.
 *
 *
 *  The function expects an event object as argument which holds
 *  a reference to the element which is subject to the state change
 *  in its currentTarget property. After setting the value of the
 *  aria-live attribute the event object is returned for further
 *  processing.
 *
 *
 *  @param { Event } event
 *
 *  An event object with a reference to the element to change.
 *
 *
 *  @return { Event }
 *
 *  The provided event.
 *
 *
 *
 */
function makeLiveRegionAssertive (event) {
  event.currentTarget.setAttribute('aria-live', 'assertive');
  return event;
}





/**
 *  @function muteLiveRegion
 *
 *
 *  @summary
 *
 *  Turns off the aria-live attribute.
 *
 *
 *  @description
 *
 *  When focus is lost on the element whose confirmation behavior
 *  is implemented by this module, than it is set back to its default
 *  state by removing a class and restoring the original text content.
 *  Because the element is declared a live region beforehand, with the
 *  politeness level set to assertive, this state change would be read
 *  aloud for screen reader users, though this is not necessary and
 *  will likely interrupt their work flow.
 *
 *
 *  Therefore this function sets the value of the aria-live attribute
 *  to off, until another focus will raise the level to assertive again.
 *  The element to augment is expected to be provided via an event
 *  object, that is also returned after changing the attribute.
 *
 *
 *  @param { Event } event
 *
 *  An event object with a reference to the object to change.
 *
 *
 *  @return { Event }
 *
 *  The provided event.
 *
 *
 *
 */
function muteLiveRegion (event) {
  event.currentTarget.setAttribute('aria-live', 'off');
  return event;
}





// Add behavior to all prepared elements.

ready(event => all('[data-confirm]').forEach(addConfirmationBehavior));
