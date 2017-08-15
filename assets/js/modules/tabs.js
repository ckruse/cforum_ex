/**
 *  @module tabs
 *
 *
 *  @summary
 *
 *  Adds functionality for tabs.
 *
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
 *  @requires predicates
 *
 *  @requires selectors
 *
 *
 *
 */





import { children, firstElementSibling, focus, lastElementSibling, nextElementSibling, previousElementSibling, siblings, toggleHiddenState, toggleTabIndex } from './elements.js';

import { bind, key, preventDefault, ready, target } from './events.js'

import { compose, memoize, pipe } from './functional.js';

import { find, tail, transform } from './lists.js';

import { both, conditions, either, unless } from './logic.js';

import { equal } from './predicates.js';

import { classes, id } from './selectors.js';





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

      [key('ArrowLeft'), pipe(
        target,
        either(previousElementSibling, lastElementSibling),
        switchTabs
      )],

      [key('ArrowRight'), pipe(
        target,
        either(nextElementSibling, firstElementSibling),
        switchTabs
      )],

      [key('Home'), pipe(preventDefault, target, firstElementSibling, switchTabs)],

      [key('End'), pipe(preventDefault, target, lastElementSibling, switchTabs)]

    ])

  });
}





function switchTabs (tab) {
  const process = both(
    pipe(
      getCurrentTabSelection, toggleSelection, toggleTabIndex,
      getAssociatedTabpanel, toggleHiddenState
    ),
    pipe(toggleSelection, toggleTabIndex, focus, getAssociatedTabpanel, toggleHiddenState)
  );

  return process(tab);
}





function getCurrentTabSelection (tab) {
  return find(selected, siblings(tab));
}



const getAssociatedTabpanel = memoize(function (tab) {
  return id(tab.getAttribute('aria-controls'));
});




/**
 *  @function selected
 *
 *
 *
 */
function selected (element) {
  return equal(element.getAttribute('aria-selected'), 'true');
}





function toggleSelection (element) {
  element.hasAttribute('aria-selected') ? element.removeAttribute('aria-selected') : element.setAttribute('aria-selected', 'true');
  return element;
}





/**
 *  @function replaceFallbackWithTablist
 *
 *
 *
 */
function replaceFallbackWithTablist (template) {
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
  const tabpanel = tab.panel;

  tabpanel.setAttribute('aria-labelledby', tab.id), tabpanel.setAttribute('role', 'tabpanel');
  return tabpanel;
}




/**
 *  @function main
 *
 *
 *
 */
ready(function main (event) {
  compose(setupTabpanels, setupTabs, replaceFallbackWithTablist(id('tablist')));
});
