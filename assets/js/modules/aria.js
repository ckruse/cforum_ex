/**
 *  @module aria
 *
 *
 *  @requires functional
 *
 *
 *
 */





import { curry } from './functional.js';

import { equal } from './predicates.js';





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
