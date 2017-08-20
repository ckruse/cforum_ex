/**
 *  @module tabs
 *
 *
 *  @summary
 *
 *  Replaces internal navigation with a tab interface.
 *
 *
 *  @description
 *
 *  This module creates a tab interface from prepared content. In
 *  case there is a template element with the ID tablist, it will take
 *  this elements content to replace a fallback navigation, which is
 *  presumed to be the previous element sibling of the template. After
 *  replacing the navigation with the tablist and setting up the state,
 *  all but the first elements that are meant to be tabpanels are
 *  hidden. When one of the tabs is activated, the current content
 *  is hidden and the newly selected content is made visible.
 *
 *
 *  @todo
 *
 *  The biggest part of this module must be refactored, because
 *  there have been too many subsequent changes causing disarray,
 *  and ultimately a poor handling of control flow. Additionaly most
 *  of the logic related to keyboard control should not be part of
 *  this module, since it can be reused for other components, too.
 *
 *
 *  @requires aria
 *
 *  @requires browser
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





import {

  controls,
  role,
  selected,
  toggleSelection

} from './aria.js';





import { hasHiddenAttribute } from './browser.js';





import {

  children,
  elementSiblings,
  firstElementSibling,
  focus,
  lastElementSibling,
  nextElementSibling,
  previousElementSibling,
  setAttribute,
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
  memoize,
  pipe

} from './functional.js';





import { find, transform } from './lists.js';





import {

  both,
  conditions,
  either,
  unless,
  when

} from './logic.js';





import { defined } from './predicates.js';

import { id } from './selectors.js';





/**
 *  @function addTabBehavior
 *
 *
 *  @summary
 *
 *  Implements tabbing behavior to a given element.
 *
 *
 *  @description
 *
 *  This function takes an element that is meant to be a tab
 *  and registers event handlers for this element. If the element
 *  gets clicked, it is checked if it already is the selected tab,
 *  and if not, this element is activated and the formerly active
 *  tab is disabled. On keydown it is first determined which tab
 *  should be activated next, before selecting the new and
 *  unselecting the old tab.
 *
 *
 *  @param { Element } tab
 *
 *  The tab to add behavior to.
 *
 *
 *  @return { Element }
 *
 *  The element provided to this function.
 *
 *
 *
 */
function addTabBehavior (tab) {
  return bind(tab, {

    click: pipe(preventDefault, target, unless(selected, switchTabs)),

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
 *  @summary
 *
 *  Returns the element controlled by another element.
 *
 *
 *  @description
 *
 *  This is just a wrapper for the controls function, which
 *  takes an element and returns the element whose ID is the
 *  value of the former elements aria-controls attribute. It
 *  is used to reference the tabpanel that is associated with
 *  a tab. To avoid having to search the DOM in every call,
 *  this function uses memoization, so the results of the
 *  controls function can be read from a cache.
 *
 *
 *  @param { Element } tab
 *
 *  The tab whose associated tabpanel to find.
 *
 *
 *  @return { Element }
 *
 *  The tabpanel controlled by the tab.
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
const currentSelection = pipe(elementSiblings, find(selected));





/**
 *  @function switchTo
 *
 *
 *  @summary
 *
 *  Switches between two tabs when a key was pressed.
 *
 *
 *  @description
 *
 *  In case a keydown event occurs on the currently selected tab,
 *  it must be determined which tab should be activated next. So this
 *  function takes a callback which is called with a reference to the
 *  currently selected tab. The return value of this selector function
 *  is expected to be the tab that is the target of the operation.
 *  Then this function removes the old selection and changes the
 *  state of the provided tab to selected.
 *
 *
 *  @param { function } selector
 *
 *  A function that returns the tab to activate.
 *
 *
 *  @return { Element }
 *
 *  The tabpanel of the newly selected tab.
 *
 *
 *
 */
function switchTo (selector) {
  return pipe(preventDefault, target, selector, when(defined, switchTabs));
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
 *  @description
 *
 *  This function takes the newly selected tab and sets
 *  focus on it. After that the tabs aria-selected attribute
 *  is set to true and its tabindex attribute is changed such
 *  that the element is placed in the documents taborder. To
 *  complete the state change, the tabpanel associated with
 *  the tab is made visible.
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
 *  @summary
 *
 *  Changes the state of a tab to unselected.
 *
 *
 *  @description
 *
 *  This is the counterpart to the enableActiveTab function. It
 *  takes the tab that should become the selected tab and uses this
 *  element to find the tab which is currently selected. It then
 *  disables the currently selected tab by setting its aria-selected
 *  attribute to false, removing it from taborder and by hiding the
 *  tabpanel that is controlled by this tab.
 *
 *
 *  @param { Element } tab
 *
 *  The newly selected tab.
 *
 *
 *  @return { Element }
 *
 *  The tabpanel of the formerly selected tab.
 *
 *
 *
 */
const disableActiveTab = pipe(currentSelection, toggleTabAndTabpanel);





/**
 *  @function switchTabs
 *
 *
 *  @summary
 *
 *  Disables the active tab and enables the selected tab.
 *
 *
 *  @description
 *
 *  This function takes the newly selected tab and returns the
 *  panel that is associated with it. When called, the function
 *  first disables the currently active tab and hides its panel,
 *  then it enables the newly selected tab and makes the
 *  panel it controls visible.
 *
 *
 *  @param { Element } tab
 *
 *  The newly selected tab.
 *
 *
 *  @return { Element }
 *
 *  The tabpanel associated with the selected tab.
 *
 *
 *
 */
const switchTabs = both(disableActiveTab, enableSelectedTab);





/**
 *  @function setupTabInterface
 *
 *
 *  @summary
 *
 *  Implements the logic for the tab interface.
 *
 *
 *  @description
 *
 *  This function expects to be called with a reference to the
 *  template whose content is the prepared tablist. It replaces
 *  the fallback for the tab interface with the retrieved tablist,
 *  complements missing attributes on the elements that should be
 *  tabs and tabpanels, and registers event handlers on the tabs
 *  to make these elements interactive.
 *
 *
 *  @param { HTMLTemplateElement } template
 *
 *  The template for the tablist.
 *
 *
 *  @return { Element [] }
 *
 *  The list of tabpanels.
 *
 *
 *
 */
const setupTabInterface = pipe(insertTablist, children, setupTabs);





/**
 *  @function insertTablist
 *
 *
 *  @summary
 *
 *  Replaces the fallback navigation with a tablist.
 *
 *
 *  @description
 *
 *  This function is called with a reference to a template element
 *  whose content is a prepared tablist. It then replaces the fallback
 *  content with the tablist. There is no need to explicitly mark the
 *  fallback content, instead we use the convention that the template
 *  element is the next element sibling of the element which should be
 *  replaced. After the replacement the template is removed from
 *  the document.
 *
 *
 *  @param { HTMLTemplateElement } template
 *
 *  The template to use.
 *
 *
 *  @return { Element }
 *
 *  The tablist inserted into the document.
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
const setupTabs = transform(pipe(addTabBehavior, setRoleAndLabelForTabpanel, toggleHiddenState));





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
 *  @summary
 *
 *  Entry point for the program.
 *
 *
 *  @description
 *
 *  This function is executed When the DOM is fully loaded and
 *  parsed. It first checks if the hidden attribute is supported
 *  and then sets up the tab interface. In the future the feature
 *  check might be excluded, but we decided to keep it in for now
 *  to avoid having users be exposed to a dysfunctional interface.
 *  If the hidden attribute is not supported, the user has to
 *  use the fallback navigation.
 *
 *
 *  @param { Event } event
 *
 *  An event object.
 *
 *
 *  @callback
 *
 *
 *
 */
ready(function main (event) {
  when(both(defined, hasHiddenAttribute), setupTabInterface, id('tablist'));
});
