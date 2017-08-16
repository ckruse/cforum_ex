/**
 *  @module tabs
 *
 *
 *  @summary
 *
 *  Creates a tab interface.
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

    click: pipe(target, unless(selected, both(disableActiveTab, enableSelectedTab))),

    keydown: conditions([

      [key('ArrowLeft'),
       switchTo(either(previousElementSibling, lastElementSibling))],

      [key('ArrowRight'),
       switchTo(either(nextElementSibling, firstElementSibling))],

      [key('Home'),
       switchTo(firstElementSibling)],

      [key('End'),
       switchTo(lastElementSibling)]

    ])

  });
}





/**
 *  @function getTabpanel
 *
 *
 *
 */
const getTabpanel = memoize(controls);





/**
 *  @function toggleTabAndTabpanel
 *
 *
 *  @summary
 *
 *  Changes the state of a tab and its associated tabpanel.
 *
 *
 *  @description
 *
 *  This function enables or disables a tab depending on the tabs
 *  current state. If the tab is currently selected, then its aria
 *  selected attribute will be set to false and it will be removed
 *  from the documents taborder. In addition, the hidden attribute
 *  of the panel that is controlled by the tab is set, such that
 *  the panel is no longer visible. In case the tab is not
 *  selected, the opposite will happen.
 *
 *
 *  @param { Element } tab
 *
 *  A selected or unselected tab.
 *
 *
 *  @return { Element }
 *
 *  The tabpanel that is controlled by the tab.
 *
 *
 *
 */
const toggleTabAndTabpanel = pipe(toggleSelection, toggleTabIndex, getTabpanel, toggleHiddenState);





/**
 *  @function currentSelection
 *
 *
 *  @summary
 *
 *  Fetches the currently selected tab.
 *
 *
 *  @description
 *
 *  When an event occurs which indicates that another tab
 *  should be selected, then the tab which is currently selected
 *  must be disabled first. This is done by changing some of the
 *  values of the tabs attributes and by hiding its associated
 *  tabpanel. Now, to disable the currently selected tab, one
 *  has to know which tab it is. To find this out is the
 *  purpose of this function.
 *
 *
 *  @param { Element } tab
 *
 *  The newly selected tab.
 *
 *
 *  @return { Element }
 *
 *  The currently selected tab.
 *
 *
 *
 */
const currentSelection = pipe(siblings, find(selected));





/**
 *  @function switchTo
 *
 *
 *
 */
function switchTo (selector) {
  return pipe(preventDefault, target, selector, both(disableActiveTab, enableSelectedTab));
}




/**
 *  @function enableSelectedTab
 *
 *
 *  @summary
 *
 *  Changes the state of a tab to selected.
 *
 *
 *  @param { Element } tab
 *
 *  The newly selected tab.
 *
 *
 *  @return { Element }
 *
 *  The associated tabpanel.
 *
 *
 *
 */
const enableSelectedTab = pipe(focus, toggleTabAndTabpanel);





/**
 *  @function disableActiveTab
 *
 *
 *
 */
const disableActiveTab = pipe(currentSelection, toggleTabAndTabpanel);





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





/**
 *  @function setupTabs
 *
 *
 *  @summary
 *
 *  Adds tab behavior to all children of a tablist.
 *
 *
 *  @description
 *
 *  This function takes an element that is assigned the role
 *  tablist and references all of its child elements, which are
 *  expected to be initialized as tabs. It then registers event
 *  handlers on every element to make them interactive. After
 *  this, tabs can be selected to show the contents of the
 *  tabpanels that they control.
 *
 *
 *  @param { Element } tablist
 *
 *  The tablist whose children to add behavior to.
 *
 *
 *  @return { Element [] }
 *
 *  A list of tabs.
 *
 *
 *
 */
function setupTabs (tablist) {
  return transform(addTabBehavior, children(tablist));
}





/**
 *  @function setupTabpanels
 *
 *
 *  @summary
 *
 *  Initializes the elements to serve as tabpanels.
 *
 *
 *  @description
 *
 *  This function takes a list of tabs and for each references
 *  the element that should be its associated tabpanel. It then
 *  assigns these elements the role tabpanel and labels them.
 *  After this transformation it hides all tabpanels except
 *  the first one setting the hidden attribute.
 *
 *
 *  @param { Element [] } tabs
 *
 *  An array with tab elements.
 *
 *
 *  @return { Element [] }
 *
 *  An array with elements transformed to tabpanels.
 *
 *
 *
 */
function setupTabpanels (tabs) {
  return transform(toggleHiddenState, tail(transform(setRoleAndLabelForTabpanel, tabs)));
}





/**
 *  @function setRoleAndLabelForTabpanel
 *
 *
 *  @summary
 *
 *  Sets the appropriate role and labels a tabpanel.
 *
 *
 *  @description
 *
 *  To be recognized as a tabpanel by assistive software, the
 *  elements which are meant to play this role must be marked up
 *  accordingly. This function takes a designated tab, references
 *  its associated tabpanel via the value of its aria-controls
 *  attribute and adds the role tabpanel to this element. In
 *  addition, the tabpanel is labeled by the tab.
 *
 *
 *  @param { Element } tab
 *
 *  The tab whose associated panel to set up.
 *
 *
 *  @return { Element }
 *
 *  The initialized tabpanel.
 *
 *
 *
 */
function setRoleAndLabelForTabpanel (tab) {
  return compose(role('tabpanel'), setAttribute('aria-labelledby', tab.id), getTabpanel(tab));
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
