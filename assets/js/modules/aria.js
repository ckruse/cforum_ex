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





import { getAttribute, setAttribute } from './elements.js';

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
export const selected = pipe(getAttribute('aria-selected'), equal('true'));





/**
 *  @function toggleSelection
 *
 *
 *
 *
 */
export function toggleSelection (element) {
  return setAttribute('aria-selected', selected(element) ? 'false' : 'true', element);
}
