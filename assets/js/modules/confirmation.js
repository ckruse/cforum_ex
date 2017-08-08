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

import { compose, pipe } from './functional.js';

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
 *  An element to add confirmation behavior to.
 *
 *
 *  @return { Element }
 *
 *  The provided element.
 *
 *
 *
 */
function addConfirmationBehavior (element) {
  element.text = element.textContent;
  return bind(element, [

    'blur', branch(
      confirming,
      pipe(muteLiveRegion, disableConfirmationState),
      muteLiveRegion
    ),

    'click', branch(
      confirming,
      pipe(muteLiveRegion, disableConfirmationState),
      pipe(stopPropagation, preventDefault, enableConfirmationState)
    ),

    'focus', makeLiveRegionAssertive

  ]);
}





/**
 *  @function confirming
 *
 *
 *  @summary
 *
 *  Tests if an element is in the confirmation state.
 *
 *
 *  @description
 *
 *  This is a predicate function that tests if an element has
 *  a class with the name confirming, indicating that the element
 *  is in the confirmation state rather than in its default state.
 *  This function is used by the addConfirmationBehavior function
 *  to control which actions should be executed when certain
 *  events occur.
 *
 *
 *  @param { Event } event
 *
 *  An event whose current target is the element to process.
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
 *  Changes the elements state to confirmation.
 *
 *
 *  @description
 *
 *  This function takes an event object and changes the state of
 *  the element that is the events current target to confirmation.
 *  This is done by adding a class with the name confirming and by
 *  replacing the textual content with the text that is the value
 *  of the data-confirm attribute of the element. After that
 *  transformation the event object is returned.
 *
 *
 *  @param { Event } event
 *
 *  An event whose current target is the element to process.
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
  compose(replaceTextualContent, addConfirmationClass, event.currentTarget);
  return event;
}





/**
 *  @function addConfirmationClass
 *
 *
 *  @summary
 *
 *  Adds the class confirming to an elements class list.
 *
 *
 *  @description
 *
 *  This function expects to be called with an element and returns
 *  the element it has been called with. It adds the class confirming
 *  to the element via the DOMTokenList collection returned from its
 *  classList property. After that the element can be recognized as
 *  being in the confirmation state by the predicate confirming
 *  that is defined above.
 *
 *
 *  @param { Element } element
 *
 *  An element to add the class confirming to.
 *
 *
 *  @return { Element }
 *
 *  The provided element.
 *
 *
 *
 */
function addConfirmationClass (element) {
  element.classList.add('confirming');
  return element;
}





/**
 *  @function replaceTextualContent
 *
 *
 *  @summary
 *
 *  Replaces the textual content of an element.
 *
 *
 *  @description
 *
 *  This function takes an element and replaces its textual
 *  content with the value of its data-confirm attribute. Then
 *  it returns the element. The new text content of the element
 *  will be a request for confirmation. If the user confirms or
 *  if the element loses focus, the original content will be
 *  restored, but because the data-confirm attribute is not
 *  touched, it can be replaced all over again.
 *
 *
 *  @param { Element } element
 *
 *  An element whose textual content should be changed.
 *
 *
 *  @return { Element }
 *
 *  The provided element.
 *
 *
 *
 */
function replaceTextualContent (element) {
  element.textContent = element.dataset.confirm;
  return element;
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
 *  An event whose current target is the element to process.
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
  compose(restoreTextualContent, removeConfirmationClass, event.currentTarget);
  return event;
}





/**
 *  @function removeConfirmationClass
 *
 *
 *  @summary
 *
 *  Removes the class confirming from an elements class list.
 *
 *
 *  @description
 *
 *  This function expects to be called with an element and returns
 *  the element it has been called with. It removes the class with the
 *  name confirming from the element using the DOMTokenList collection
 *  returned from its classList property. After that the element will
 *  no longer be recognized as being in the confirmation state by
 *  the predicate confirming that is defined above.
 *
 *
 *  @param { Element } element
 *
 *  An element to remove the class confirming from.
 *
 *
 *  @return { Element }
 *
 *  The provided element.
 *
 *
 *
 */
function removeConfirmationClass (element) {
  element.classList.remove('confirming');
  return element;
}





/**
 *  @function restoreTextualContent
 *
 *
 *  @summary
 *
 *  Resets the textual content of an element.
 *
 *
 *  @description
 *
 *  When an element enters the confirmation state, its textual
 *  content is replaced by the value of its data-confirm attribute.
 *  In case the user confirmed the action that is associated with
 *  the element or if the element loses focus, the default state
 *  must be restored. This function then replaces the current
 *  content with the original text that has been retained
 *  in the elements text property.
 *
 *
 *  @param { Element } element
 *
 *  An element whose textual content should be restored.
 *
 *
 *  @return
 *
 *  The provided element.
 *
 *
 *
 */
function restoreTextualContent (element) {
  element.textContent = element.text;
  return element;
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





// Add behavior to all prepared elements

ready(event => all('[data-confirm]').forEach(addConfirmationBehavior));
