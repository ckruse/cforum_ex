/**
 *  @module browser.test
 *
 *
 *  @summary
 *
 *  Tests for the functions provided by the browser module.
 *
 *
 *  @description
 *
 *  The functions exported from the browser module perform feature
 *  checks, some of whom are qualified to produce exceptions in case
 *  they are not implemented properly. This module is about testing
 *  these functions to reduce the possibility of a fatal error.
 *
 *
 *  The tests are implemented using the jasmine test framework,
 *  which is expected to be available and executed at the time this
 *  module is processed. The documentation of interfaces provided
 *  by the jasemine framework is outside the scope of this file
 *  and must be obtained from other sources, preferably the
 *  offical website of the project.
 *
 *
 *  @requires browser
 *
 *
 *
 */





import * as browser from '../js/modules/browser.js';





/**
 *  @namespace tests
 *
 *
 *  @summary
 *
 *  Container for test functions.
 *
 *
 *  @description
 *
 *  There is no technical need to outsource the test functions
 *  for the module, but it improves readability and makes it easier
 *  to attach comments. Every member of the tests namespace object
 *  must have the same name as the function it is about to test.
 *  That’s because the keys of tests are used as arguments to the
 *  describe function that is provided by the jasmine library.
 *
 *
 *  Anyway, please keep in mind, that the tests should be self
 *  explanatory, so comments should only be included to provide
 *  contextual information, for example about the purpose of the
 *  tested function or about properties that are not important
 *  enough to be included into the test suite.
 *
 *
 *
 */
const tests = {};





/**
 *  @method hasLocalStorage
 *
 *
 *  @summary
 *
 *  Tests the hasLocalStorage function.
 *
 *
 *  @description
 *
 *  The hasLocalStorage function should be a nullary function
 *  that returns a boolean indicating whether the Local Storage
 *  interface is available or not. Depending on client and user
 *  configuration there are a couple of situations where the
 *  attempt to access the localStorage Object produces an
 *  exception, so this has to be tested.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.hasLocalStorage = function () {


  const { hasLocalStorage } = browser;


  describe('when called without arguments', function () {

    it('should not throw an error', function () {
      expect(jasmine.createSpy('test', hasLocalStorage).and.callThrough()).not.toThrow();
    });

    it('should return a boolean value', function () {
      expect(typeof hasLocalStorage()).toBe('boolean');
    });

  });


};





/**
 *  @method hasNotifications
 *
 *
 *  @summary
 *
 *  Tests the hasNotifications function.
 *
 *
 *  @description
 *
 *  The hasNotifications function does not expect arguments
 *  and returns a boolean value. At the time of writing there
 *  are no known issues concerning the access to this interface,
 *  so testing for errors seems to be a dispensable task.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.hasNotifications = function () {


  const { hasNotifications } = browser;


  describe('when called without arguments', function () {

    it('should return a boolean value', function () {
      expect(typeof hasNotifications()).toBe('boolean');
    });

  });


};





/**
 *  @method hasWebSocket
 *
 *
 *  @summary
 *
 *  Tests the hasWebSocket function.
 *
 *
 *  @description
 *
 *  The hasWebSocket function is a nullary function and
 *  returns a boolean value. Though referencing the object
 *  the interface is represented by will be safe most of
 *  the time, there seem to be at least some situations
 *  where an error may occur.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.hasWebSocket = function () {


  const { hasWebSocket } = browser;


  describe('when called without arguments', function () {

    it('should not throw an error', function () {
      expect(jasmine.createSpy('test', hasWebSocket).and.callThrough()).not.toThrow();
    });

    it('should return a boolean value', function () {
      expect(typeof hasWebSocket()).toBe('boolean');
    });

  });


};





// Run test functions

describe('browser', function () {
  Object.keys(tests).forEach(name => describe(name, tests[name]));
});
