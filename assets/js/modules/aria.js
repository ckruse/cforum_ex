/**
 *  @module aria
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

import { equal } from './predicates.js';

import { id } from './selectors.js';





/**
 *  @function controls
 *
 *
 *
 */
export const controls = curry(function controls (element) {
  return id(element.getAttribute('aria-controls'));
});





/**
 *  @function selected
 *
 *
 *
 */
export const selected = curry(function selected (element) {
  return equal(element.getAttribute('aria-selected'), 'true');
});





/**
 *  @function toggleSelection
 *
 *
 *
 *
 */
export const toggleSelection = curry(function toggleSelection (element) {
  element.setAttribute('aria-selected', selected(element) ? 'false' : 'true');
  return element;
});
