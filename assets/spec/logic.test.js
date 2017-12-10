/**
 *  @module logic.test
 *
 *
 *  @summary
 *
 *  Tests the functions provided by the logic module.
 *
 *
 *  @description
 *
 *  The tests are implemented using the jasmine test framework,
 *  which is expected to be available and executed at the time this
 *  module is processed. The documentation of interfaces provided
 *  by the jasemine framework is outside the scope of this file
 *  and must be obtained from other sources, preferably the
 *  offical website of the project.
 *
 *
 *  @requires functional
 *
 *  @requires logic
 *
 *
 *
 */





import * as logic from '../js/modules/logic.js';


import { binary, falsy, identity, truthy } from '../js/modules/functional.js';





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
 *  @constant { Spy } spy
 *
 *
 *  @summary
 *
 *  A proxy object to examine function calls.
 *
 *
 *  @description
 *
 *  The spy object provided by the jasmine library can be
 *  used as a placeholder for functions. Together with the
 *  objects returned from the expect method, it is easy to
 *  determine, whether a function hat been called or not,
 *  or which and how many arguments have been passed.
 *
 *
 *  However, please note that spies do remember previous
 *  invokations, so it is important when using this global
 *  instance, to always call its reset method after usage.
 *  If this is omitted, subsequent tests involving the
 *  same spy will likely be tainted.
 *
 *
 *  @ignore
 *
 *
 *
 */
const spy = jasmine.createSpy('test');





/**
 *  @method and
 *
 *
 *  @summary
 *
 *  Tests the and function.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.and = function () {


  const { and } = logic;


  describe('when called with two arguments', function () {

    it('should return the first operand if it’s falsy', function () {
      expect(and(false, true)).toBe(false);
    });

    it('should return the second operand if the first one is truthy', function () {
      expect(and(true, false)).toBe(false);
    });

  });


};





/**
 *  @method both
 *
 *
 *  @summary
 *
 *  Tests the both function.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.both = function () {


  const { both } = logic;


  describe('when called with two function arguments', function () {

    it('should return a function', function () {
      expect(typeof both(truthy, falsy)).toBe('function');
    });


    describe('then the function returned', function () {

      it('should have an arity that equals the lesser of the two operands', function () {
        expect(both(identity, binary(identity)).length).toBe(1);
      });


      describe('when called with enough arguments', function () {

        it('should invoke the first operand with its arguments', function () {
          both(spy, identity)(true), expect(spy).toHaveBeenCalledWith(true);

          spy.calls.reset();
        });


        describe('and when the first operand returns a falsy value', function () {

          it('should not invoke the second operand', function () {
            both(falsy, spy)(true), expect(spy).not.toHaveBeenCalled();

            spy.calls.reset();
          });

          it('should return the result of the first operand', function () {
            expect(both(falsy, truthy)(true)).toBe(false);
          });

        });


        describe('and when the first operand returns a truthy value', function () {

          it('should invoke the second operand with its arguments', function () {
            both(truthy, spy)(1, 2, 3), expect(spy).toHaveBeenCalledWith(1, 2, 3);

            spy.calls.reset();
          });

          it('should return the result of the second operand', function () {
            expect(both(truthy, falsy)(true)).toBe(false);
          });

        });

      });

    });

  });


};





/**
 *  @method branch
 *
 *
 *  @summary
 *
 *  Tests the branch function.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.branch = function () {


  const { branch } = logic;


  describe('when called with three function arguments', function () {

    it('should return a function', function () {
      expect(typeof branch(Boolean, truthy, falsy)).toBe('function');
    });


    describe('then the function returned', function () {

      it('should have the same arity as the first operand', function () {
        expect(branch(Boolean, truthy, falsy).length).toBe(1);
      });


      describe('when called with enough arguments', function () {

        it('should invoke the first operand with its arguments', function () {
          branch(spy, truthy, falsy)(true), expect(spy).toHaveBeenCalledWith(true);

          spy.calls.reset();
        });


        describe('and when the first operand returned a truthy value', function () {

          it('should invoke the second operand with its arguments', function () {
            branch(Boolean, spy, falsy)(true), expect(spy).toHaveBeenCalledWith(true);

            spy.calls.reset();
          });

          it('should not invoke the third operand', function () {
            branch(Boolean, truthy, spy)(true), expect(spy).not.toHaveBeenCalled();

            spy.calls.reset();
          });

          it('should return the result of the second operand', function () {
            expect(branch(Boolean, truthy, falsy)(true)).toBe(true);
          });

        });


        describe('and when the first operand returned a falsy value', function () {

          it('should invoke the third operand with its arguments', function () {
            branch(Boolean, truthy, spy)(false), expect(spy).toHaveBeenCalledWith(false);

            spy.calls.reset();
          });

          it('should not invoke the second operand', function () {
            branch(Boolean, spy, falsy)(false), expect(spy).not.toHaveBeenCalled();

            spy.calls.reset();
          });

          it('should return the result of the third operand', function () {
            expect(branch(Boolean, truthy, falsy)(false)).toBe(false);
          });

        });

      });

    });

  });


};





/**
 *  @method conditions
 *
 *
 *  @summary
 *
 *  Tests the conditions function.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.conditions = function () {


  const { conditions } = logic;


  describe('when called with an array of function pairs', function () {

    it('should return a function', function () {
      const value = conditions([
        [truthy, identity]
      ]);

      expect(typeof value).toBe('function');
    });


    describe('then the function returned when called with any arguments', function () {

      it('should call every predicate until one of them returns a truthy value', function () {
        spy.and.returnValue(false);

        const init = conditions([
          [spy, identity],
          [truthy, identity],
          [spy, identity]
        ]);

        init(null), expect(spy).toHaveBeenCalledTimes(1);

        spy.and.stub(), spy.calls.reset();
      });

      it('should call the predicate functions with its arguments', function () {
        const init = conditions([
          [spy, identity]
        ]);

        init(true), expect(spy).toHaveBeenCalledWith(true);

        spy.calls.reset();
      });


      describe('when one predicate returned a truthy value', function () {

        it('should call the associated function with its arguments', function () {
          const init = conditions([
            [falsy, identity],
            [truthy, spy]
          ]);

          init(true), expect(spy).toHaveBeenCalledWith(true);

          spy.calls.reset();
        });

        it('should return the value returned from the associated function', function () {
          const init = conditions([
            [truthy, identity]
          ]);

          expect(init(true)).toBe(true);
        });

      });


      describe('when all predicate functions returned falsy values', function () {

        it('should not call any associated functions', function () {
          const init = conditions([
            [falsy, spy],
            [falsy, spy]
          ]);

          init(null), expect(spy).not.toHaveBeenCalled();

          spy.calls.reset();
        });

        it('should return false', function () {
          const init = conditions([
            [falsy, identity]
          ]);

          expect(init(true)).toBe(false);
        });

      });

    });

  });


};





/**
 *  @method complement
 *
 *
 *  @summary
 *
 *  Tests the complement function.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.complement = function () {


  const { complement } = logic;


  describe('when called with a function argument', function () {

    it('should return a function', function () {
      expect(typeof complement(identity)).toBe('function');
    });


    describe('then the function returned', function () {

      it('should have the same arity as the function provided', function () {
        expect(complement(identity).length).toBe(1);
      });


      describe('when called with enough arguments', function () {

        it('should invoke the operand function with its arguments', function () {
          complement(spy)(true), expect(spy).toHaveBeenCalledWith(true);

          spy.calls.reset();
        });

        it('should return false if the operand returned a truthy value', function () {
          expect(complement(truthy)(true)).toBe(false);
        });

        it('should return true if the operand returned a falsy value', function () {
          expect(complement(falsy)(false)).toBe(true);
        });

      });

    });

  });


};





/**
 *  @method either
 *
 *
 *  @summary
 *
 *  Tests the either function.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.either = function () {


  const { either } = logic;


  describe('when called with two function arguments', function () {

    it('should return a function', function () {
      expect(typeof either(truthy, falsy)).toBe('function');
    });


    describe('then the function returned', function () {

      it('should have an arity that equals the lesser of the two operands', function () {
        expect(either(identity, binary(identity)).length).toBe(1);
      });


      describe('when called with enough arguments', function () {

        it('should invoke the first operand with its arguments', function () {
          either(spy, identity)(true), expect(spy).toHaveBeenCalledWith(true);

          spy.calls.reset();
        });


        describe('and when the first operand returns a truthy value', function () {

          it('should not invoke the second operand', function () {
            either(truthy, spy)(true), expect(spy).not.toHaveBeenCalled();

            spy.calls.reset();
          });

          it('should return the result of the first operand', function () {
            expect(either(truthy, falsy)(true)).toBe(true);
          });

        });


        describe('and when the first operand returns a falsy value', function () {

          it('should invoke the second operand with its arguments', function () {
            either(falsy, spy)(true), expect(spy).toHaveBeenCalledWith(true);

            spy.calls.reset();
          });

          it('should return the result of the second operand', function () {
            expect(either(falsy, truthy)(true)).toBe(true);
          });

        });

      });

    });

  });


};





/**
 *  @method not
 *
 *
 *  @summary
 *
 *  Tests the not function.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.not = function () {


  const { not } = logic;


  describe('when called with one argument', function () {

    it('should return false if the argument is a truthy value', function () {
      expect(not(true)).toBe(false);
    });

    it('should return true if the argument is a falsy value', function () {
      expect(not(false)).toBe(true);
    });

  });


};





/**
 *  @method or
 *
 *
 *  @summary
 *
 *  Tests the or function.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.or = function () {


  const { or } = logic;


  describe('when called with two arguments', function () {

    it('should return the first operand if it’s truthy', function () {
      expect(or(true, false)).toBe(true);
    });

    it('should return the second operand if the first one is falsy', function () {
      expect(or(false, true)).toBe(true);
    });

  });


};





/**
 *  @method unless
 *
 *
 *  @summary
 *
 *  Tests the unless function.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.unless = function () {


  const { unless } = logic;


  describe('when called with two functions and an arbitrary value', function () {

    it('should invoke the first function with the provided value', function () {
      unless(spy, identity, true), expect(spy).toHaveBeenCalledWith(true);

      spy.calls.reset();
    });


    describe('and the first function returned a truthy value', function () {

      it('should not call the second function', function () {
        unless(truthy, spy, null), expect(spy).not.toHaveBeenCalled();

        spy.calls.reset();
      });

      it('should return the value of the third argument', function () {
        expect(unless(truthy, identity, true)).toBe(true);
      });

    });


    describe('and the first function returned a falsy value', function () {

      it('should invoke the second function with the provided value', function () {
        unless(falsy, spy, true), expect(spy).toHaveBeenCalledWith(true);

        spy.calls.reset();
      });

      it('should return the value from calling the second function', function () {
        expect(unless(falsy, truthy, null)).toBe(true);
      });

    });

  });


};





/**
 *  @method when
 *
 *
 *  @summary
 *
 *  Tests the when function.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.when = function () {


  const { when } = logic;


  describe('when called with two functions and an arbitrary value', function () {

    it('should invoke the first function with the provided value', function () {
      when(spy, identity, true), expect(spy).toHaveBeenCalledWith(true);

      spy.calls.reset();
    });


    describe('and the first function returned a falsy value', function () {

      it('should not call the second function', function () {
        when(falsy, spy, null), expect(spy).not.toHaveBeenCalled();

        spy.calls.reset();
      });

      it('should return the value of the third argument', function () {
        expect(when(falsy, identity, true)).toBe(true);
      });

    });


    describe('and the first function returned a truthy value', function () {

      it('should invoke the second function with the provided value', function () {
        when(truthy, spy, true), expect(spy).toHaveBeenCalledWith(true);

        spy.calls.reset();
      });

      it('should return the value from calling the second function', function () {
        expect(when(truthy, falsy, null)).toBe(false);
      });

    });

  });


};





// Run test functions

describe('logic', function () {
  Object.keys(tests).forEach(name => describe(name, tests[name]));
});
