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





import { getAttribute } from './elements.js';

import { curry, pipe } from './functional.js';

import { equal } from './predicates.js';

import { id } from './selectors.js';





/**
 *  @function controls
 *
 *
 *  @param { Element } element
 *
 *
 *  @return { Element }
 *
 *
 *
 */
export const controls = pipe(getAttribute('aria-controls'), id);





/**
 *  @function role
 *
 *
 *
 */
export const role = setAttribute('role');





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
