/**
 *  @module browser
 *
 *
 *  @summary
 *
 *  Provides feature checks.
 *
 *
 *  @description
 *
 *  Because some useful features are not supported by every
 *  platform we have to take into consideration, there is a need
 *  for checks. So this module contains functions that test if
 *  certain interfaces are available and can be used as intended.
 *  Those functions typically do not expect arguments and return
 *  a boolean value indicating the test result.
 *
 *
 *  @requires predicates
 *
 *
 *
 */





import { defined, equal } from './predicates.js';





/**
 *  @function hasHiddenAttribute
 *
 *
 *  @summary
 *
 *  Tests if the HTML hidden attribute is supported.
 *
 *
 *  @description
 *
 *  Unfortunately there are still some browsers around that
 *  do not support the HTML hidden attribute. To avoid exposing
 *  broken interfaces to the users this function can be used to
 *  check if the attribute is available. If not, fallback
 *  content can be presented.
 *
 *
 *  @return { boolean }
 *
 *  The result of the test.
 *
 *
 *
 */
export function hasHiddenAttribute () {
  return 'hidden' in document.body;
}





/**
 *  @function hasLocalStorage
 *
 *
 *  @summary
 *
 *  Tests if the Local Storage API is available.
 *
 *
 *  @description
 *
 *  There are several situations where referencing the localStorage
 *  object causes an exception to be thrown, so to avoid breaking the
 *  program one has to use try and catch. In some cases though, it’s
 *  not the reference causing the error but the attempt to set an
 *  item. Therefore testing for existence is not enough here and
 *  we actually have to try to set and remove an item.
 *
 *
 *  @return { boolean }
 *
 *  Result of the test.
 *
 *
 *
 */
export function hasLocalStorage () {

  try {
    localStorage.setItem('test', 'value'), localStorage.removeItem('test');
    return true;
  }
  catch (exception) {
    return false;
  }

}





/**
 *  @function hasNotifications
 *
 *
 *  @summary
 *
 *  Tests if the Notifications API is available.
 *
 *
 *  @description
 *
 *  Referencing the Notification constructor is expected to be safe,
 *  so there should be no need for try and catch. Anyway, please note
 *  that this test is only about the availability of the API and does
 *  not imply that the required permission is granted. This has to
 *  be checked independently.
 *
 *
 *  @return { boolean }
 *
 *  Result of the test.
 *
 *
 *
 */
export function hasNotifications () {
  return defined(window.Notification) && defined(window.Notification.requestPermission);
}





/**
 *  @function hasWebSocket
 *
 *
 *  @summary
 *
 *  Tests if the Web Socket API ist available.
 *
 *
 *  @description
 *
 *  Checking for existance of the WebSocket object should be
 *  safe, but it looks like there are indeed circumstances where
 *  an error may occur, so the test is wrapped in try and catch.
 *  This test will only yield true if the standard interface is
 *  supported, that is, proprietary implementations with or
 *  without prefix are rejected.
 *
 *
 *  @return { boolean }
 *
 *  Result of the test.
 *
 *
 *
 */
export function hasWebSocket () {

  try {
    return equal(WebSocket.CLOSING, 2);
  }
  catch (exception) {
    return false;
  }

}
