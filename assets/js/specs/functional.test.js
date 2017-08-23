/**
 *  @module functional.test
 *
 *
 *  @summary
 *
 *  Tests for the functions provided by the module functional.
 *
 *
 *  @description
 *
 *  The functions exported from the module functional cover a wide
 *  range of applications and can be considered a framework for the
 *  actual program logic, providing abstractions that are potentially
 *  used in many other places. Therefore it is crucial that these
 *  functions work as specified. To verify this is the purpose
 *  of this module.
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
 *  @requires functional
 *
 *
 *
 */





import * as functional from '../modules/functional.js';





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
 *  @method apply
 *
 *
 *  @summary
 *
 *  Tests the apply function.
 *
 *
 *  @description
 *
 *  The test assumes that apply is a function that expects at
 *  least one argument, which is required to be a function object.
 *  In case the first parameter of apply is initialized with a value
 *  that does not have an internal [[call]] method, an exception
 *  will be thrown. The same outcome can be achived by passing
 *  a second argument that is not an array-like object.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.apply = function () {


  const { apply } = functional;


  describe('when called with one function argument', function () {

    it('should invoke the function provided without arguments', function () {
      apply(spy), expect(spy).toHaveBeenCalledWith();

      spy.calls.reset();
    });

    it('should return the value returned from the function', function () {
      expect(apply(functional.truthy)).toBe(true);
    });

  });


  describe('when called with a function and an array', function () {

    it('should invoke the function with the values contained in the array', function () {
      apply(spy, [true, false]), expect(spy).toHaveBeenCalledWith(true, false);

      spy.calls.reset();
    });

    it('should return the value returned from the function', function () {
      expect(apply(functional.identity, [true])).toBe(true);
    });

  });


};





/**
 *  @method binary
 *
 *
 *  @summary
 *
 *  Tests the binary function.
 *
 *
 *  @description
 *
 *  The binary function should take a single function argument
 *  which is then converted into a binary function, by providing
 *  a guard that calls the operand with its first two arguments.
 *  For this test it is presumed, that the guard function itself
 *  is curried, such that the operand is not called with less
 *  than two arguments either.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.binary = function () {


  const { binary } = functional;


  describe('when called with one function argument', function () {

    it('should return a binary function', function () {
      expect(binary(functional.identity).length).toBe(2);
    });


    describe('then the function returned', function () {

      it('should call the operand only with its first two arguments', function () {
        binary(spy)(1, 2, 3), expect(spy).toHaveBeenCalledWith(1, 2);

        spy.calls.reset();
      });

      it('should return the result of calling the operand', function () {
        expect(binary(functional.truthy)(false, false)).toBe(true);
      });

    });

  });


};





/**
 *  @method call
 *
 *
 *  @summary
 *
 *  Tests the call function.
 *
 *
 *  @description
 *
 *  The call function does nothing more than calling its
 *  operand with an arbitrary number of arguments. For this
 *  test it is assumed, that the first value passed to call
 *  is a function object. Supplying a value that is not
 *  callable will produce a type error.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.call = function () {


  const { call } = functional;


  describe('when called with one function argument', function () {

    it('should invoke the function provided without arguments', function () {
      call(spy), expect(spy).toHaveBeenCalledWith();

      spy.calls.reset();
    });

    it('should return the value returned from the function', function () {
      expect(call(functional.truthy)).toBe(true);
    });

  });


  describe('when called with more than one argument', function () {

    it('should invoke the function with all additional arguments', function () {
      call(spy, 1, 2, 3), expect(spy).toHaveBeenCalledWith(1, 2, 3);

      spy.calls.reset();
    });

    it('should return the value returned from the function', function () {
      expect(call(functional.identity, true)).toBe(true);
    });

  });


};





/**
 *  @method compose
 *
 *
 *  @summary
 *
 *  Tests the compose function.
 *
 *
 *  @description
 *
 *  The compose function calls one function with the result
 *  of calling another function. So, it requires the first two
 *  arguments to be functions. Additional arguments however are
 *  optional. In case one of the first two values passed in
 *  is not callable, a type error will be thrown.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.compose = function () {


  const { compose } = functional;


  describe('when called with two function arguments', function () {

    it('should invoke the second function provided without arguments', function () {
      compose(functional.identity, spy), expect(spy).toHaveBeenCalledWith();

      spy.calls.reset();
    });

    it('should invoke the first function with the value returned from the second', function () {
      compose(spy, functional.truthy), expect(spy).toHaveBeenCalledWith(true);

      spy.calls.reset();
    });

    it('should return the result of calling the first function', function () {
      expect(compose(functional.truthy, functional.falsy)).toBe(true);
    });

  });


  describe('when called with two functions and additional values', function () {

    it('should invoke the second function provided with these values', function () {
      compose(functional.identity, spy, 1, 2, 3), expect(spy).toHaveBeenCalledWith(1, 2, 3);

      spy.calls.reset();
    });

    it('should invoke the first function with the value returned from the second', function () {
      compose(spy, functional.identity, true), expect(spy).toHaveBeenCalledWith(true);

      spy.calls.reset();
    });

    it('should return the result of calling the first function', function () {
      expect(compose(functional.truthy, functional.identity, false)).toBe(true);
    });

  });


};





/**
 *  @method constant
 *
 *
 *  @summary
 *
 *  Tests the constant function.
 *
 *
 *  @description
 *
 *  The constant function binds a value to a function. It
 *  is expected to be a unary function that returns another
 *  function that always returns the provided value, no
 *  matter which arguments are passed in or to which
 *  value the function context has been bound.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.constant = function () {


  const { constant } = functional;


  describe('when called with one argument', function () {

    it('should return a nullary function', function () {
      expect(constant(true).length).toBe(0);
    });


    describe('then the function returned', function () {

      it('should return the value provided to constant', function () {
        expect(constant(true)()).toBe(true);
      });

      it('should ignore any arguments passed in', function () {
        expect(constant(true)(false)).toBe(true);
      });

    });

  });


};





/**
 *  @method curry
 *
 *
 *  @summary
 *
 *  Tests the curry function.
 *
 *
 *  @description
 *
 *  The curry function auto-curries the function it is applied
 *  to. Since most of the utility functions that are not nullary
 *  functions are defined using curry, the whole house of cards
 *  will collapse if it doesn’t work properly.
 *
 *
 *  This test assumes that curry is always called either without
 *  arguments, with a single function argument or with a function
 *  and an array. If the first argument is not callable or the
 *  second one is not an array, this will inevitably cause
 *  an exception to be thrown.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.curry = function () {


  const { curry } = functional;


  describe('when called with one function argument', function () {

    it('should return a function', function () {
      expect(typeof curry(functional.identity)).toBe('function');
    });


    describe('then the function returned', function () {

      it('should have the same arity as the provided function', function () {
        expect(curry(functional.binary(functional.identity)).length).toBe(2);
      });

      it('should have the same name as the provided function', function () {
        expect(curry(functional.identity).name).toBe('identity');
      });


      describe('when called with enough arguments', function () {

        it('should call the function provided to curry with its arguments', function () {
          curry(spy)(true), expect(spy).toHaveBeenCalledWith(true);

          spy.calls.reset();
        });

        it('should return the result of calling the provided function', function () {
          expect(curry(functional.identity)(true)).toBe(true);
        });

      });


      describe('when called repeatedly with enough arguments', function () {

        it('should not remember arguments passed in previous calls', function () {
          const test = curry(functional.binary(spy));

          test(true)(false), expect(spy).toHaveBeenCalledWith(true, false);

          spy.calls.reset();

          test(false)(true), expect(spy).toHaveBeenCalledWith(false, true);

          spy.calls.reset();
        });

      });


      describe('when called with fewer arguments than expected', function () {

        it('should not invoke the provided function', function () {
          curry(functional.binary(spy))(true), expect(spy).not.toHaveBeenCalled();

          spy.calls.reset();
        });

        it('should return a function expecting the remaining arguments', function () {
          expect(curry(functional.identity)().length).toBe(1);
        });

        it('should return functions until all required arguments are collected', function () {
          const test = curry(functional.ternary(functional.truthy));

          let result = test(1);
          expect(typeof result).toBe('function');

          result = result(2);
          expect(typeof result).toBe('function');

          result = result(3);
          expect(typeof result).toBe('boolean');
        });

        it('should call the provided function when there are enough arguments', function () {
          curry(functional.binary(spy))(true)(false), expect(spy).toHaveBeenCalled();

          spy.calls.reset();
        });

        it('should return the result of calling the provided function', function () {
          expect(curry(functional.binary(functional.truthy))(false, true)).toBe(true);
        });

      });


      describe('when called with arrays as arguments', function () {

        it('should not flatten the arguments list', function () {
          curry(functional.ternary(spy))(1)([2])(3), expect(spy).toHaveBeenCalledWith(1, [2], 3);

          spy.calls.reset();
        });

      });

    });

  });


  describe('when called with a function and an array', function () {

    it('should return a function', function () {
      expect(typeof curry(functional.identity, [true])).toBe('function');
    });


    describe('then the function returned', function () {

      it('should expect as many arguments as its target minus the array length', function () {
        expect(curry(functional.binary(functional.identity), [true]).length).toBe(1);
      });

      it('should not have a length property smaller than zero', function () {
        expect(curry(functional.identity, [true, false]).length).toBe(0);
      });

      it('should pass the values in the array first', function () {
        curry(functional.ternary(spy), [1, 2])(3), expect(spy).toHaveBeenCalledWith(1, 2, 3);

        spy.calls.reset();
      });

    });

  });


};





/**
 *  @method define
 *
 *
 *  @summary
 *
 *  Tests the define function.
 *
 *
 *  @description
 *
 *  The define function is used to set the length and name
 *  properties of functions. Because it is used by the curry
 *  function it is not auto-curried, so calling it with less
 *  than three arguments produces an error. Not providing a
 *  number for the first and a string for second parameter
 *  will not directly produce an error, though.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.define = function () {


  const { define } = functional;


  describe('when called with a number and a string and a function', function () {

    const test = function () {};

    it('should assign the number to the length property of the function', function () {
      expect(define(1, 'test', test).length).toBe(1);
    });

    it('should assign zero if the number is negative', function () {
      expect(define(1 - 2, 'test', test).length).toBe(0);
    });

    it('should assign the string to the name property of the function', function () {
      expect(define(test.length, 'name', test).name).toBe('name');
    });

    it('should return the function it has been called with', function () {
      expect(define(test.length, test.name, test)).toBe(test);
    });

  });


  describe('when called with fewer arguments than required', function () {

    it('should throw an exception', function () {
      expect(jasmine.createSpy('define', define).and.callThrough()).toThrow();
    });

  });


};





/**
 *  @method defineFrom
 *
 *
 *  @summary
 *
 *  Tests the defineFrom function.
 *
 *
 *  @description
 *
 *  The defineFrom function copies the values of the length
 *  and name properties from one function to another. In case
 *  the first argument is a value that cannot be coerced to an
 *  object a type error will immediately be thrown. If the
 *  second argument is not an object, then this will
 *  produce a type error during definition.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.defineFrom = function () {


  const { defineFrom } = functional;


  describe('when called with two function arguments', function () {

    const test = function test () {};

    it('should assign the name and length property of the first to the second', function () {
      defineFrom(functional.unary, test);

      expect(test.length).toBe(1), expect(test.name).toBe('unary');
    });

    it('should return the second function', function () {
      expect(defineFrom(functional.identity, test)).toBe(test);
    });

  });


};





/**
 *  @method falsy
 *
 *
 *  @summary
 *
 *  Tests the falsy function.
 *
 *
 *  @description
 *
 *  The function falsy does not expect any arguments
 *  and always returns the boolean value false. Calling
 *  falsy with any number of arguments or explicitly
 *  setting the function context should not have
 *  any effect on the outcome.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.falsy = function () {


  const { falsy } = functional;


  describe('when called without arguments', function () {

    it('should return the primitive value false', function () {
      expect(falsy()).toBe(false);
    });

  });


  describe('when called with arguments', function () {

    it('should ignore the values passed in and return false', function () {
      expect(falsy(1, 2, 3)).toBe(false);
    });

  });


};





/**
 *  @method flip
 *
 *
 *  @summary
 *
 *  Tests the flip function.
 *
 *
 *  @description
 *
 *  The flip function takes a function argument and returns
 *  a function with the same arity. When this function is called
 *  it invokes the operand function with its arguments list reversed.
 *  Additionally the function passed to flip will be called in the
 *  same context as the function that has been returned. In case
 *  the value passed to flip is not callable, an error will be
 *  thrown when the returned function is invoked.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.flip = function () {


  const { flip } = functional;


  describe('when called with a function argument', function () {

    it('should return a function', function () {
      expect(typeof flip(functional.identity)).toBe('function');
    });


    describe('then the function returned', function () {

      it('should have the same arity as the function provided', function () {
        expect(flip(functional.identity).length).toBe(1);
      });

      it('should call the target function with its arguments reversed', function () {
        flip(functional.ternary(spy))(1, 2, 3), expect(spy).toHaveBeenCalledWith(3, 2, 1);

        spy.calls.reset();
      });

      it('should return the value returned from the operand', function () {
        expect(flip(functional.identity)(true)).toBe(true);
      });

    });

  });


};





/**
 *  @method identity
 *
 *
 *  @summary
 *
 *  Tests the identity function.
 *
 *
 *  @description
 *
 *  The identity function simply returns the value it
 *  has been called with. In case more than one argument
 *  is passed in, then the additional arguments should
 *  be ignored, just as any binding for the context.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.identity = function () {


  const { identity } = functional;


  describe('when called with one argument', function () {

    it('should return the argument', function () {
      expect(identity(true)).toBe(true), expect(identity(false)).toBe(false);
    });

  });


  describe('when called with more than one argument', function () {

    it('should return the first argument', function () {
      expect(identity(1, 2, 3)).toBe(1);
    });

  });


};





/**
 *  @method memoize
 *
 *
 *  @summary
 *
 *  Tests the memoize function.
 *
 *
 *  @description
 *
 *  The memoize function wrapps around another function,
 *  intercepting calls to this function. It checks if the operand
 *  has been called before with the same set of arguments and if
 *  so, returns the cached result. Otherwise it calls the function
 *  it guards. The test of the arguments is a test for equality,
 *  so different objects containing the same values will not be
 *  considered to be the same, though this might change in
 *  future implementations.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.memoize = function () {


  const { memoize } = functional;


  describe('when called with one function argument', function () {

    it('should return a function', function () {
      expect(typeof memoize(functional.identity)).toBe('function');
    });


    describe('then the function returned', function () {

      it('should have the same arity as the operand', function () {
        expect(memoize(functional.identity).length).toBe(1);
      });


      describe('when called with enough arguments', function () {

        const add = function (first, second) {
          spy(first, second); return first + second;
        };


        it('should call the function provided with its arguments', function () {
          memoize(add)(1, 2), expect(spy).toHaveBeenCalledWith(1, 2);

          spy.calls.reset();
        });

        it('should return the value returned from the operand', function () {
          expect(memoize(add)(1, 2)).toBe(3);

          spy.calls.reset();
        });


        describe('and when called with the same arguments before', function () {

          it('should not call the operand again', function () {
            const test = memoize(add);

            test(1, 2), test(1, 2), expect(spy).toHaveBeenCalledTimes(1);

            spy.calls.reset();
          });

          it('should return the cached result', function () {
            const test = memoize(add);

            expect(test(1, 2) - test(1, 2)).toBe(0);

            spy.calls.reset();
          });

        });

      });

    });

  });


};





/**
 *  @method once
 *
 *
 *  @summary
 *
 *  Tests the once function.
 *
 *
 *  @description
 *
 *  The function once expects to be called with a function and
 *  returns a guard which takes care that the provided function
 *  is only called once, returning the cached result of the first
 *  call in every subsequent invokation. In case the once function
 *  is called with a value that cannot be coerced to an object, an
 *  exception will be thrown directly. Additionally, if the value
 *  passed to once is not callable, invoking the closure
 *  returned from once will throw a type error.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.once = function () {


  const { once } = functional;


  describe('when called with one function argument', function () {

    it('should return a function', function () {
      expect(typeof once(functional.identity)).toBe('function');
    });


    describe('then the function returned', function () {

      it('should have the same arity as the operand function', function () {
        expect(once(functional.identity).length).toBe(1);
      });


      describe('when called with enough arguments', function () {

        it('should invoke the function provided to once with its arguments', function () {
          once(spy)(true, false), expect(spy).toHaveBeenCalledWith(true, false);

          spy.calls.reset();
        });

        it('should return the result of invoking the operand', function () {
          expect(once(functional.identity)(true)).toBe(true);
        });


        describe('and the target function had been called before', function () {

          it('should not call the target function again', function () {
            const test = once(spy);

            test(true), test(true), expect(spy).toHaveBeenCalledTimes(1);

            spy.calls.reset();
          });

          it('should return the result of the first call', function () {
            const test = once(functional.identity);

            test(true), expect(test(false)).toBe(true);
          });

        });

      });

    });

  });


};





/**
 *  @method partial
 *
 *
 *  @summary
 *
 *  Tests the partial function.
 *
 *
 *  @description
 *
 *  The function partial performs partial function application,
 *  that is, it binds a number of arguments to a function and returns
 *  another function that gathers the remaining arguments. Then this
 *  function calls the function provided to partial with all collected
 *  values. Depending on the type of value passed as first argument to
 *  partial, an error may be thrown either by accessing the length
 *  and name properties of the value or at the time of calling.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.partial = function () {


  const { partial } = functional;


  describe('when called with one function argument', function () {

    it('should return a function', function () {
      expect(typeof partial(functional.identity)).toBe('function');
    });


    describe('then the function returned', function () {

      it('should have the same arity as the function provided to partial', function () {
        expect(partial(functional.identity).length).toBe(1);
      });


      describe('when called with enough arguments', function () {

        it('should invoke the provided function with its arguments', function () {
          partial(spy)(true, false), expect(spy).toHaveBeenCalledWith(true, false);

          spy.calls.reset();
        });

        it('should not flatten the arguments list', function () {
          partial(spy)(1, [2], 3), expect(spy).toHaveBeenCalledWith(1, [2], 3);

          spy.calls.reset();
        });

        it('should return the result of calling the operand', function () {
          expect(partial(functional.identity)(true)).toBe(true);
        });

      });

    });

  });


  describe('when called with a function and additional arguments', function () {

    it('should return a function', function () {
      expect(typeof partial(functional.identity, true)).toBe('function');
    });


    describe('then the function returned', function () {

      it('should match the arity of the operand minus the provided values', function () {
        expect(partial(functional.binary(functional.identity), true).length).toBe(1);
      });

      it('should not have a length property smaller than zero', function () {
        expect(partial(functional.identity, 1, 2, 3).length).toBe(0);
      });


      describe('when called with enough arguments', function () {

        it('should invoke the operand with the arguments from both calls', function () {
          partial(spy, 1, 2)(3), expect(spy).toHaveBeenCalledWith(1, 2, 3);

          spy.calls.reset();
        });

        it('should not flatten the the arguments lists', function () {
          partial(spy, [1])(2, [3]), expect(spy).toHaveBeenCalledWith([1], 2, [3]);

          spy.calls.reset();
        });

        it('should return the value of calling the operand', function () {
          expect(partial(functional.truthy, false)(false)).toBe(true);
        });

      });


      describe('when called more than once', function () {

        it('should always concat the initial and the current arguments', function () {
          const applied = partial(spy, 1);

          applied(2, 3), expect(spy).toHaveBeenCalledWith(1, 2, 3);

          spy.calls.reset();

          applied(4, 5), expect(spy).toHaveBeenCalledWith(1, 4, 5);

          spy.calls.reset();
        });

      });

    });

  });


};





/**
 *  @method partialReversed
 *
 *
 *  @summary
 *
 *  Tests the partialReversed function.
 *
 *
 *  @description
 *
 *  The partialReversed function is much like the function
 *  partial in that it partially applies its operand. The sole
 *  difference is the order in which the arguments supplied to
 *  partialReversed and to the closure returned are passed on
 *  to the operand. Therefore, just as with partial an error
 *  will be thrown if the first argument provided is not
 *  a function object.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.partialReversed = function () {


  const { partialReversed } = functional;


  describe('when called with one function argument', function () {

    it('should return a function', function () {
      expect(typeof partialReversed(functional.identity)).toBe('function');
    });


    describe('then the function returned', function () {

      it('should have the same arity as the function provided to partialReversed', function () {
        expect(partialReversed(functional.identity).length).toBe(1);
      });


      describe('when called with enough arguments', function () {

        it('should invoke the provided function with its arguments', function () {
          partialReversed(spy)(true, false), expect(spy).toHaveBeenCalledWith(true, false);

          spy.calls.reset();
        });

        it('should not flatten the arguments list', function () {
          partialReversed(spy)(1, [2], 3), expect(spy).toHaveBeenCalledWith(1, [2], 3);

          spy.calls.reset();
        });

        it('should return the result of calling the operand', function () {
          expect(partialReversed(functional.identity)(true)).toBe(true);
        });

      });

    });

  });


  describe('when called with a function and additional arguments', function () {

    it('should return a function', function () {
      expect(typeof partialReversed(functional.identity, true)).toBe('function');
    });


    describe('then the function returned', function () {

      it('should match the arity of the operand minus the provided values', function () {
        expect(partialReversed(functional.binary(functional.identity), true).length).toBe(1);
      });

      it('should not have a length property smaller than zero', function () {
        expect(partialReversed(functional.identity, 1, 2, 3).length).toBe(0);
      });


      describe('when called with enough arguments', function () {

        it('should call the operand with its arguments before the initial values', function () {
          partialReversed(spy, 2, 3)(1), expect(spy).toHaveBeenCalledWith(1, 2, 3);

          spy.calls.reset();
        });

        it('should not flatten the arguments lists', function () {
          partialReversed(spy, [3])([1], 2), expect(spy).toHaveBeenCalledWith([1], 2, [3]);

          spy.calls.reset();
        });

        it('should return the value of calling the operand', function () {
          expect(partialReversed(functional.truthy, false)(false)).toBe(true);
        });

      });


      describe('when called more than once', function () {

        it('should always put the current arguments before the initial values', function () {
          const applied = partialReversed(spy, 5);

          applied(3, 4), expect(spy).toHaveBeenCalledWith(3, 4, 5);

          spy.calls.reset();

          applied(1, 2), expect(spy).toHaveBeenCalledWith(1, 2, 5);

          spy.calls.reset();
        });

      });

    });

  });


};





/**
 *  @method pipe
 *
 *
 *  @summary
 *
 *  Tests the pipe function.
 *
 *
 *  @description
 *
 *  The function to test is a variadic function performing
 *  left to right function composition. If one of the arguments
 *  passed to pipe is not a function, this will cause an error
 *  to be thrown, either when calling pipe itself or at the
 *  time when the closure returned from pipe is called.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.pipe = function () {


  const { pipe } = functional;


  describe('when called with at least one function argument', function () {

    const { identity } = functional;

    it('should return a function', function () {
      expect(typeof pipe(identity)).toBe('function');
    });


    describe('then the function returned', function () {

      it('should have an arity that matches that of the first function argument', function () {
        expect(pipe(functional.binary(identity), identity).length).toBe(2);
      });


      describe('when called with enough arguments', function () {

        it('should call the leftmost function with all of its arguments', function () {
          pipe(spy, identity)(true, false), expect(spy).toHaveBeenCalledWith(true, false);

          spy.calls.reset();
        });


        describe('and when only a single function operand had been provided', function () {

          it('should return the result of invoking that function', function () {
            expect(pipe(identity)(true)).toBe(true);
          });

        });


        describe('and when more than one function operand had been provided', function () {

          it('should call every operand with the result of its predecessor', function () {
            expect(pipe(identity, identity, identity)(true)).toBe(true);
          });

          it('should return the result of the last function called', function () {
            expect(pipe(identity, identity, functional.truthy)(false)).toBe(true);
          });

        });

      });

    });

  });


};





/**
 *  @method prepare
 *
 *
 *  @summary
 *
 *  Tests the prepare function.
 *
 *
 *  @description
 *
 *  The function to test takes a target function and an array
 *  of transformer functions. It returns a function that invokes
 *  every transformer with the argument that has the same index
 *  and passes the transformed values to the target function. If
 *  the first argument to prepare is not a function, the second
 *  argument not an array, or any of the arrays elements is not
 *  a function, then a type error will be thrown.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.prepare = function () {


  const { prepare } = functional;


  describe('when called with one function and an array of transformers', function () {

    const { identity } = functional;

    it('should return a function', function () {
      expect(typeof prepare(identity, [identity])).toBe('function');
    });


    describe('then the function returned', function () {

      it('should have the same arity as the target function', function () {
        expect(prepare(identity, [identity]).length).toBe(1);
      });


      describe('when called with enough arguments', function () {

        it('should call every transformer with the argument at the same index', function () {
          prepare(identity, [spy, spy])(true, false);

          expect(spy).toHaveBeenCalledTimes(2);

          const [first] = spy.calls.first().args, [second] = spy.calls.mostRecent().args;

          expect(first).toBe(true), expect(second).toBe(false);

          spy.calls.reset();
        });

        it('should call the target function with the transformed arguments', function () {
          prepare(spy, [identity, identity])(1, 2), expect(spy).toHaveBeenCalledWith(1, 2);

          spy.calls.reset();
        });

        it('should return the result returned from the target function', function () {
          expect(prepare(identity, [identity])(true)).toBe(true);
        });

      });


      describe('when called with less arguments than transformers provided', function () {

        it('should substitute the value undefined', function () {
          prepare(spy, [identity, identity])(true);

          expect(spy).toHaveBeenCalledWith(true, undefined);

          spy.calls.reset();
        });

      });


      describe('when called with more arguments than transformers provided', function () {

        it('should append the surplus to the transformed arguments', function () {
          prepare(spy, [identity])(1, 2, 3),

          expect(spy).toHaveBeenCalledWith(1, 2, 3);

          spy.calls.reset();
        });

      });

    });

  });


  describe('when called with a function and an empty array', function () {

    it('should call the target function with the raw values', function () {
      expect(prepare(functional.identity, [])(true)).toBe(true);
    });

    it('should not thow an exception', function () {
      const test = () => prepare(functional.identity, [])(true);

      expect(jasmine.createSpy('useWith', test).and.callThrough()).not.toThrow();
    });

  });


};





/**
 *  @method substitute
 *
 *
 *  @summary
 *
 *  Tests the substitute function.
 *
 *
 *  @description
 *
 *  The substitute function takes two functions and an arbitrary
 *  number of additional arguments. It calls the first function with
 *  the arguments provided, then it calls the function returned from
 *  the first function with thre result of calling the second function
 *  with the same set of arguments, effectively substituting the
 *  first function call.
 *
 *
 *  Both functions the first two arguments of substitute are
 *  initialized with are invoked in the context that is bound to
 *  substitute. In case the first or the second argument to substitute
 *  is not callable, a type error will be thrown. In addition, the
 *  first function provided must be a higher order function returning
 *  another function. If the returned value is not a function, then
 *  this will also produce an error.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.substitute = function () {


  const { substitute } = functional;


  describe('when called with two functions and any number of additional values', function () {

    it('should call the first function with the provided values', function () {
      const test = value => (spy(value), functional.identity);

      substitute(test, functional.identity, true), expect(spy).toHaveBeenCalledWith(true);

      spy.calls.reset();
    });

    it('should call the second function with the provided values', function () {
      const test = value => functional.identity;

      substitute(test, spy, true), expect(spy).toHaveBeenCalledWith(true);

      spy.calls.reset();
    });

    it('should call the result of the first with the result of the second', function () {
      const test = value => spy;

      substitute(test, functional.identity, true), expect(spy).toHaveBeenCalledWith(true);

      spy.calls.reset();
    });

    it('should return the result of calling the function returned from the first', function () {
      expect(substitute(value => functional.truthy, functional.identity, false)).toBe(true);
    });

  });


};





/**
 *  @method ternary
 *
 *
 *  @summary
 *
 *  Tests the ternary function.
 *
 *
 *  @description
 *
 *  The ternary function should take a single function argument
 *  which is then converted into a ternary function, by providing
 *  a guard that calls the operand with its first three arguments.
 *  For this test it is presumed, that the guard function itself
 *  is curried, such that the operand is not called with less
 *  than three arguments either.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.ternary = function () {


  const { ternary } = functional;


  describe('when called with one function argument', function () {

    it('should return a ternary function', function () {
      expect(ternary(functional.identity).length).toBe(3);
    });


    describe('then the function returned', function () {

      it('should call the operand only with its first three arguments', function () {
        ternary(spy)(1, 2, 3, 4), expect(spy).toHaveBeenCalledWith(1, 2, 3);

        spy.calls.reset();
      });

      it('should return the result of calling the operand', function () {
        expect(ternary(functional.truthy)(false, false, false)).toBe(true);
      });

    });

  });


};





/**
 *  @method truthy
 *
 *
 *  @summary
 *
 *  Tests the truthy function.
 *
 *
 *  @description
 *
 *  The function truthy does not expect any arguments
 *  and always returns the boolean value true. Calling
 *  truthy with any number of arguments or explicitly
 *  setting the function context should not have
 *  any effect on the outcome.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.truthy = function () {


  const { truthy } = functional;


  describe('when called without arguments', function () {

    it('should return the primitive value true', function () {
      expect(truthy()).toBe(true);
    });

  });


  describe('when called with arguments', function () {

    it('should ignore the values passed in and return true', function () {
      expect(truthy(1, 2, 3)).toBe(true);
    });

  });


};





/**
 *  @method unapply
 *
 *
 *  @summary
 *
 *  Tests the unapply function.
 *
 *
 *  @description
 *
 *  The function to test is the inverse of the apply function,
 *  that means it expects to be called with a function and returns
 *  another function, which calls the operand with an array of its
 *  arguments. The second parameter of unapply, used to set the
 *  length property of the function returned, is optionl and
 *  defaults to one. In case the first argument passed to
 *  unapply is not a function, an error will occur.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.unapply = function () {


  const { unapply } = functional;


  describe('when called with a function and a number', function () {

    it('should return a function', function () {
      expect(typeof unapply(functional.identity, 1)).toBe('function');
    });


    describe('then the function returned', function () {

      it('should expect as many arguments as specified by the second parameter', function () {
        expect(unapply(functional.identity, 2).length).toBe(2);
      });


      describe('when called with enough arguments', function () {

        it('should call the provided function with its arguments in an array', function () {
          unapply(spy, 3)(1, 2, 3), expect(spy).toHaveBeenCalledWith([1, 2, 3]);

          spy.calls.reset();
        });

        it('should not flatten the arguments list', function () {
          unapply(spy, 3)(1, [2], 3), expect(spy).toHaveBeenCalledWith([1, [2], 3]);

          spy.calls.reset();
        });

        it('should return the result of calling the operand', function () {
          const [result] = unapply(functional.identity, 1)(true);

          expect(result).toBe(true);
        });

      });

    });

  });


};





/**
 *  @method unary
 *
 *
 *  @summary
 *
 *  Tests the unary function.
 *
 *
 *  @description
 *
 *  The unary function should take a single function argument
 *  which is then converted into an unary function, by providing
 *  a guard that calls the operand only with its first argument.
 *  For this test it is presumed, that the guard function itself
 *  is curried, such that the operand is not called without
 *  an argument either.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.unary = function () {


  const { unary } = functional;


  describe('when called with one function argument', function () {

    it('should return a ternary function', function () {
      expect(unary(functional.binary(functional.identity)).length).toBe(1);
    });


    describe('then the function returned', function () {

      it('should call the operand only with its first argument', function () {
        unary(spy)(1, 2), expect(spy).toHaveBeenCalledWith(1);

        spy.calls.reset();
      });

      it('should return the result of calling the operand', function () {
        expect(unary(functional.truthy)(false)).toBe(true);
      });

    });

  });


};





/**
 *  @method wrap
 *
 *
 *  @summary
 *
 *  Tests the wrap function.
 *
 *
 *  @description
 *
 *  The wrap function expects two function arguments and
 *  returns another function. The returned function invokes the
 *  second function with a reference to the first and all values
 *  it has been called with. If the first argument to wrap can’t
 *  be coerced to an object or the second value passed to wrap
 *  is not callable, an exception will be thrown.
 *
 *
 *  @memberof tests
 *
 *
 *
 */
tests.wrap = function () {


  const { wrap } = functional;


  describe('when called with two function arguments', function () {

    const { identity } = functional;

    it('should return a function', function () {
      expect(typeof wrap(identity, identity)).toBe('function');
    });


    describe('then the function returned', function () {

      it('should have the same arity as the first function operand', function () {
        expect(wrap(identity, functional.binary(identity)).length).toBe(1);
      });


      describe('when called with enough arguments', function () {

        it('should call the second function with the first plus arguments', function () {
          wrap(identity, spy)(true), expect(spy).toHaveBeenCalledWith(identity, true);

          spy.calls.reset();
        });

        it('should not flatten the arguments list', function () {
          wrap(identity, spy)(1, [2], 3), expect(spy).toHaveBeenCalledWith(identity, 1, [2], 3);

          spy.calls.reset();
        });

        it('should return the result of calling the second function', function () {
          expect(wrap(identity, (target, value) => value)(true)).toBe(true);
        });

      });

    });

  });


};





// Run test functions

describe('functional', function () {
  Object.keys(tests).forEach(name => describe(name, tests[name]))
});
