/**
 *  @module aria
 *
 *
 *  @requires functional
 *
 *  @requires predicates
 *
 *  @requires selectors
 *
 *
 *
 */





import { curry } from './functional.js';

import { equal } from './predicates.js';

import { id } from './selectors.js';





/**
 *  @function controls
 *
 *
 *
 */
export function controls (element) {
  return id(element.getAttribute('aria-controls'));
}





/**
 *  @function role
 *
 *
 *
 */
export const role = curry(function role (value, element) {
  element.setAttribute('role', value);
  return element;
})





/**
 *  @function selected
 *
 *
 *
 */
export function selected (element) {
  return equal(element.getAttribute('aria-selected'), 'true');
}





/**
 *  @function toggleSelection
 *
 *
 *
 *
 */
export function toggleSelection (element) {
  element.setAttribute('aria-selected', selected(element) ? 'false' : 'true');
  return element;
}
