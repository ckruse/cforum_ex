/**
 *  @module predicates.test
 *
 *
 *  @summary
 *
 *  Tests the functions provided by the predicates module.
 *
 *
 *  @requires predicates
 *
 *
 *
 */





import * as predicates from '../js/modules/predicates.js';





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
 *  @method array
 *
 *
 *  @summary
 *
 *  Tests the array function.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.array = function () {


  const { array } = predicates;


  describe('when called with any value', function () {

    it('should return true if the value is an array', function () {
      expect(array([])).toBe(true);
    });

    it('should return false if the value is not an array', function () {
      expect(array(arguments)).toBe(false);
    });

  });


};





/**
 *  @method defined
 *
 *
 *  @summary
 *
 *  Tests the defined function.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.defined = function () {


  const { defined } = predicates;


  describe('when called with one argument', function () {

    it('should return false for null', function () {
      expect(defined(null)).toBe(false);
    });

    it('should return false for undefined', function () {
      expect(defined(undefined)).toBe(false);
    });

    it('should return true for all other types', function () {
      const test = Type => defined(Type());

      expect([Boolean, Object, Number, String, Symbol].every(test)).toBe(true);
    });

  });


};





// Run test functions

describe('predicates', function () {
  Object.keys(tests).forEach(name => describe(name, tests[name]));
});
