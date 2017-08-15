/**
 *  @module aria
 *
 *
 *
 */






/**
 *  @function selected
 *
 *
 *
 */
export const selected = curry(function selected (element) {
  return equal(element.getAttribute('aria-selected'), 'true');
});
