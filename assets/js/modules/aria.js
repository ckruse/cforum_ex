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





/**
 *  @function selected
 *
 *
 *
 */
export const selected = curry(function selected (element) {
  return equal(element.getAttribute('aria-selected'), 'true');
});
