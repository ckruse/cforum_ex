/**
 *  @module tabs
 *
 *
 *  @summary
 *
 *  Adds functionality for tabs.
 *
 *
 *  @requires aria
 *
 *  @requires elements
 *
 *  @requires events
 *
 *  @requires functional
 *
 *  @requires lists
 *
 *  @requires logic
 *
 *  @requires selectors
 *
 *
 *
 */





import {

  controls,
  role,
  selected,
  toggleSelection

} from './aria.js';



import {

  children,
  firstElementSibling,
  focus,
  lastElementSibling,
  nextElementSibling,
  previousElementSibling,
  setAttribute,
  siblings,
  toggleHiddenState,
  toggleTabIndex

} from './elements.js';



import {

  bind,
  key,
  preventDefault,
  ready,
  target

} from './events.js'



import {

  compose,
  curry,
  memoize,
  pipe

} from './functional.js';



import {

  find,
  tail,
  transform

} from './lists.js';



import {

  both,
  conditions,
  either,
  unless

} from './logic.js';



import { id } from './selectors.js';





/**
 *  @function addTabBehavior
 *
 *
 *
 */
function addTabBehavior (tab) {
  return bind(tab, {

    click: pipe(target, unless(selected, switchTabs)),

    keydown: conditions([

      [key('ArrowLeft'),
       to(either(previousElementSibling, lastElementSibling))],

      [key('ArrowRight'),
       to(either(nextElementSibling, firstElementSibling))],

      [key('Home'),
       to(firstElementSibling)],

      [key('End'),
       to(lastElementSibling)]

    ])

  });
}





function switchTabs (tab) {
  const process = both(
    pipe(
      siblings, find(selected), toggleSelection, toggleTabIndex,
      getAssociatedTabpanel, toggleHiddenState
    ),
    pipe(toggleSelection, toggleTabIndex, focus, getAssociatedTabpanel, toggleHiddenState)
  );

  return process(tab);
}







const to = curry(function to (selector, event) {
  return pipe(preventDefault, target, selector, switchTabs)(event);
});







const getAssociatedTabpanel = memoize(controls);






/**
 *  @function insertTablist
 *
 *
 *
 */
function insertTablist (template) {
  const tablist = template.content.firstElementChild;

  template.parentNode.replaceChild(tablist, template.previousElementSibling), template.remove();
  return tablist
}








function setupTabs (tablist) {
  return compose(transform(addTabBehavior), connectTabsWithTabpanels, children(tablist));
}




function connectTabsWithTabpanels (tabs) {
  tabs.forEach(tab => tab.panel = id(tab.getAttribute('aria-controls')));
  return tabs;
}



function setupTabpanels (tabs) {
  return pipe(transform(setRoleAndLabelForTabpanel), tail, transform(toggleHiddenState))(tabs);
}



function setRoleAndLabelForTabpanel (tab) {
  return compose(role('tabpanel'), setAttribute('aria-labelledby', tab.id), getAssociatedTabpanel(tab));
}




/**
 *  @function main
 *
 *
 *
 */
ready(function main (event) {
  compose(setupTabpanels, setupTabs, insertTablist(id('tablist')));
});
