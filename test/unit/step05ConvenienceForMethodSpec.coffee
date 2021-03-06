CrunchTask = CrunchTask
Promise = Promise

if (typeof require is 'function')
  CrunchTask = require('../../lib/crunchtask')
  Promise = require('../../node_modules/promise-polyfill/Promise')
  utils = require('./utils.coffee')

root = typeof window is 'object' && window ? window : global
type = root.type || utils.type
whenAll = root.whenAll || utils.whenAll

describe 'CrunchTask convenience methods Spec.', ->

  describe 'CrunchTask convenience static methods:', ->
    it 'declares static deprecated `for()` method', ()->
      expect(CrunchTask.for).toBeDefined()
      expect(type(CrunchTask.for)).toEqual('function')
      return

    it 'declares static `range()` method (supercedes `for()`)', ()->
      expect(CrunchTask.range).toBeDefined()
      expect(type(CrunchTask.range)).toEqual('function')
      return

    it 'declares static `rangeCheck()` method', ()->
      expect(CrunchTask.rangeCheck).toBeDefined()
      expect(type(CrunchTask.rangeCheck)).toEqual('function')
      return

    it '`rangeCheck()` method returns an instance of Range class which has methods:`::valueOf()` and `::canAdvance([bool])`', ()->
      range = CrunchTask.rangeCheck(1, 2, true)

      expect(range.valueOf).toBeDefined()
      expect(type(range.valueOf)).toEqual('function')

      expect(range.canAdvance).toBeDefined()
      expect(type(range.canAdvance)).toEqual('function')
      return

    it 'declares static `forEach()` method', ()->
      expect(CrunchTask.forEach).toBeDefined()
      expect(type(CrunchTask.forEach)).toEqual('function')
      return

    it 'declares static `reduce()` method', ()->
      expect(CrunchTask.reduce).toBeDefined()
      expect(type(CrunchTask.reduce)).toEqual('function')
      return

    it 'declares static `config()` method', ()->
      expect(CrunchTask.config).toBeDefined()
      expect(type(CrunchTask.config)).toEqual('function')
      return

    return

  describe '`rangeCheck()` method parses the arguments into async-for-loop-ready structure', ()->
    it 'no arguments produces empty ranges array and is OK', ()->
      expect(CrunchTask.rangeCheck().valueOf()).toEqual([])
      return
    it 'only numerics, bools, and arrays are considered as args', ()->
      `var undef;`
      expect(CrunchTask.rangeCheck('123', undef, /123/).valueOf()).toEqual([])
      return
    it 'a valid range is represented by the array of 3 numbers and an `inclusive` flag', ()->
      expect(CrunchTask.rangeCheck(0, 9, .5, true).data).toEqual([
        {
          from: 0,
          current: 0,
          to: 9,
          step: .5,
          inclusive: true
        } ])
      return

    it 'the first number represents a range\'s `from` value', ()->
      from = 5
      expect(CrunchTask.rangeCheck(from, 9, .5, true).data[0].from).toEqual(from)
      from = -5
      expect(CrunchTask.rangeCheck(from, 9, .5, true).data[0].from).toEqual(from)
      return

    it 'the second number represents a range\'s `to` value', ()->
      to = 5
      expect(CrunchTask.rangeCheck(5, to, .5, true).data[0].to).toEqual(to)
      to = -5
      expect(CrunchTask.rangeCheck(5, to, .5, true).data[0].to).toEqual(to)
      return

    it 'the third number represents a `step` value ', ()->
      step = 5
      expect(CrunchTask.rangeCheck(0, 9, step, true).data[0].step).toEqual(step)
      step = -5
      expect(CrunchTask.rangeCheck(0, 9, step, true).data[0].step).toEqual(step)
      step = .5
      expect(CrunchTask.rangeCheck(0, 9, step, true).data[0].step).toEqual(step)
      return

    it 'if the `step` is omitted, it defaults to +1 if (`from` <= `to`), and -1 otherwise', ()->
      from = 0
      to = 10
      expect(CrunchTask.rangeCheck(from, to).data[0].step).toEqual(+1)
      from = 10
      to = 10
      expect(CrunchTask.rangeCheck(from, to).data[0].step).toEqual(+1)
      from = 10
      to = 0
      expect(CrunchTask.rangeCheck(from, to).data[0].step).toEqual(-1)
      from = 0
      to = 10
      expect(CrunchTask.rangeCheck(from, to, false).data[0].step).toEqual(+1)
      from = 10
      to = 10
      expect(CrunchTask.rangeCheck(from, to, false).data[0].step).toEqual(+1)
      from = 10
      to = 0
      expect(CrunchTask.rangeCheck(from, to, false).data[0].step).toEqual(-1)
      return

    it 'if the `inclusive` is omitted, it defaults to `false`', ()->
      expect(CrunchTask.rangeCheck(0, 9).data[0].inclusive).toEqual(false);
      expect(CrunchTask.rangeCheck(0, 9, .5).data[0].inclusive).toEqual(false);
      return

    it 'so the minimum of two numbers define a range `0,10` mean `from 0 to 10`', ()->
      expect(()->
        CrunchTask.rangeCheck(0, 9)
      ).not.toThrow()
      return

    it 'less than 2 numeric arguments do not represent a valid range and an error is thrown', ()->
      expect(()->
        CrunchTask.rangeCheck(0)
      ).toThrow()

      expect(()->
        CrunchTask.rangeCheck(0,true)
      ).toThrow()
      return

    it 'two or more ranges can be defined in a flat list if `inclusive` flag is supplied for each', ()->
      expect(()->
        CrunchTask.rangeCheck(0, 9, 1, true, 9, 0, -1, true)
        CrunchTask.rangeCheck(0, 9, 1, true, 9, 0, -1, true, 5, 1, false)
      ).not.toThrow()

      expect(CrunchTask.rangeCheck(0, 9, 1, true, 9, 0, -1, true).data
      ).toEqual([
            { from: 0, current: 0, to: 9, step: 1, inclusive: true },
            { from: 9, current: 9, to: 0, step: -1, inclusive: true } ])

      expect(CrunchTask.rangeCheck(0, 9, 1, true, 9, 0, -1, true, 5, 1, false).data
      ).toEqual([
            { from: 0, current: 0, to: 9, step: 1, inclusive: true },
            { from: 9, current: 9, to: 0, step: -1, inclusive: true },
            { from: 5, current: 5, to: 1, step: -1, inclusive: false } ])
      return

    it 'this way, the bools serve as comma. Thus the last bool can be omitted if need be', ()->
      expect(()->
        CrunchTask.rangeCheck(0, 9, 1, true, 9, 0, -1, true, 5, 1)
      ).not.toThrow()

      expect(CrunchTask.rangeCheck(0, 9, 1, true, 9, 0, -1, true, 5, 1).data
      ).toEqual([
            { from: 0, current: 0, to: 9, step: 1, inclusive: true },
            { from: 9, current: 9, to: 0, step: -1, inclusive: true },
            { from: 5, current: 5, to: 1, step: -1, inclusive: false } ])
      return

    it 'however, this cannot be done safely for mid-list bools, they are obligatory', ()->
      expect(()->
        CrunchTask.rangeCheck(0, 9, 1, 9, 0, -1)
      ).toThrow()

      expect(()->
        CrunchTask.rangeCheck(0, 9, 1, 9, 0, -1, 5, 1)
      ).toThrow()

      expect(()->
        CrunchTask.rangeCheck(0, 9, 1, 9)
      ).toThrow()
      return

    it 'it can be advised to use arrays to group individual ranges', ()->
      expect(()->
        CrunchTask.rangeCheck([0, 9], [1, 9])
      ).not.toThrow()
      return

    it 'the same rules apply to these individual array as for the flat list args described above. Nested arrays are ignored, though', ()->
      expect(()->
        CrunchTask.rangeCheck([0, 9, [1, 9]])
      ).not.toThrow()

      expect(CrunchTask.rangeCheck([0, 9, [1, 9]]).data
      ).toEqual([
            { from: 0, current: 0, to: 9, step: 1, inclusive: false } ])
      return

    it 'arrays can be mixed with the valid ranges chains with expected valid results', ()->
      result = null
      expect(()->
        result = CrunchTask.rangeCheck([0, 9], 9, 0, -.5, false, 9, 0, -.5, [1, 9, true], 9, 0, -.5, false,[0,5])
      ).not.toThrow()

      expect(result.data).toEqual([
        { from: 0, current: 0, to: 9, step: 1, inclusive: false },
        { from: 9, current: 9, to: 0, step: -0.5, inclusive: false },
        { from: 9, current: 9, to: 0, step: -0.5, inclusive: false },
        { from: 1, current: 1, to: 9, step: 1, inclusive: true },
        { from: 9, current: 9, to: 0, step: -0.5, inclusive: false },
        { from: 0, current: 0, to: 5, step: 1, inclusive: false } ])
      return

    it 'ranges can be used to imitate binary permutation', ()->
      expect(CrunchTask.rangeCheck(0, 1, true, 0, 1, true, 0, 1, true).data
      ).toEqual([
            { from: 0, current: 0, to: 1, step: 1, inclusive: true },
            { from: 0, current: 0, to: 1, step: 1, inclusive: true },
            { from: 0, current: 0, to: 1, step: 1, inclusive: true } ])
      return

    return

  describe '`range::canAdvance()` method tries to advance the current position of the ranges structure', ()->
    range = null;

    beforeEach(()->
      range = CrunchTask.rangeCheck(0, 1, true)
    )

    it 'advances the elements of the range structure and responds whether it has not reached the end yet (hasn\'t looped over)', ()->
      expect(range.canAdvance()).toBe(true)
      return

    it 'inclusive range of [0..1] reaches the end in two calls.', ()->
      expect(range.canAdvance()).toBe(true)
      expect(range.canAdvance()).toBe(false)
      return

    it 'so does the inclusive range of [1..0]', ()->
      range = CrunchTask.rangeCheck(1, 0, true)
      expect(range.canAdvance()).toBe(true)
      expect(range.canAdvance()).toBe(false)
      return

    it 'non-inclusive range of [0..1) reaches end with each call', ()->
      range = CrunchTask.rangeCheck(0, 1)
      expect(range.canAdvance()).toBe(false)
      return

    it 'a non-inclusive range of [0..1) with step .5 reaches end with two calls', ()->
      range = CrunchTask.rangeCheck(0, 1, .5)
      expect(range.canAdvance()).toBe(true)
      expect(range.canAdvance()).toBe(false)
      return

    it 'so does the reverse range of [1..0) with step -.5', ()->
      range = CrunchTask.rangeCheck(1, 0, -.5)
      expect(range.canAdvance()).toBe(true)
      expect(range.canAdvance()).toBe(false)
      return

    it 'it takes four iterations to iterate fully two binary ranges [0..1]&[0..1]', ()->
      range = CrunchTask.rangeCheck(0, 1, true, 0, 1, true)
      expect(range.canAdvance()).toBe(true)
      expect(range.canAdvance()).toBe(true)
      expect(range.canAdvance()).toBe(true)
      expect(range.canAdvance()).toBe(false)
      return

    it 'doesn\'t work this way if `inclusive` isn\'t set to `true`', ()->
      range = CrunchTask.rangeCheck(0, 1, false, 0, 1, false)
      expect(range.canAdvance()).toBe(false)
      expect(range.canAdvance()).toBe(false)
      expect(range.canAdvance()).toBe(false)
      expect(range.canAdvance()).toBe(false)
      return

    return

  describe 'the `for()` method', ()->
    foo = {}
    jasmineTimeout = 5000

    beforeEach(()->
      jasmineTimeout = jasmine.DEFAULT_TIMEOUT_INTERVAL
#      jasmine.DEFAULT_TIMEOUT_INTERVAL = 15000

#      console.info CrunchTask.config(false)

      foo.bar = (() ->
      )
      foo.baz = (() ->
      )
    )

    afterEach ()->
      jasmine.DEFAULT_TIMEOUT_INTERVAL = jasmineTimeout
      delete foo.bar
      delete foo.baz

    it 'once called, the `for()` method creates a CrunchTask instance', ()->
      forLoop = CrunchTask.for(()->)
      expect(forLoop instanceof CrunchTask).toBe(true);
      return

    it 'the `for()` method accepts loop control numbers and a worker function (or two functions: body and tail) or a task', (done)->

      spyOn(foo, 'bar').and.callThrough()

      forLoop = CrunchTask.for(0, 2, (args...)->
#        console.log "2. time: #{ new Date() - 0}"
        foo.bar.apply(foo, args)
      )

      expect(foo.bar).not.toHaveBeenCalled()

      forLoop.run()
#      console.log "1. time: #{ new Date() - 0}"

      setTimeout(()->
        expect(foo.bar).toHaveBeenCalled()
        expect(foo.bar.calls.count()).toEqual(2)
        expect(foo.bar.calls.argsFor(0)).toEqual([0])
        expect(foo.bar.calls.argsFor(1)).toEqual([1])
        expect(foo.bar.calls.argsFor(2)).toEqual([])
        expect(foo.bar.calls.argsFor(2)).toEqual([])
#        console.log "3. time: #{ new Date() - 0}"
        done()
      , 4000)

      return

    it 'the loop control values, supplied for the `for()` method, are overrun by the ones supplied for the `run()` method', (done)->

      spyOn(foo, 'bar').and.callThrough()

      forLoop = CrunchTask.for(0, 2, foo.bar)

      expect(foo.bar).not.toHaveBeenCalled()

      forLoop.run(0, 5)

      setTimeout(()->
        expect(foo.bar).toHaveBeenCalled()
        expect(foo.bar.calls.count()).toEqual(5)
        expect(foo.bar.calls.argsFor(0)).toEqual([0])
        expect(foo.bar.calls.argsFor(1)).toEqual([1])
        expect(foo.bar.calls.argsFor(2)).toEqual([2])
        expect(foo.bar.calls.argsFor(3)).toEqual([3])
        expect(foo.bar.calls.argsFor(4)).toEqual([4])
        done()
      , 4000)

      return

    it 'loop-control values may be supplied in groups, their behavior is explained in the `rangeCheck()` section above', (done)->

      spyOn(foo, 'bar').and.callThrough()

      forLoop = CrunchTask.for([0, 2], [0, 2], foo.bar)

      expect(foo.bar).not.toHaveBeenCalled()

      forLoop.done( ()->
        expect(foo.bar).toHaveBeenCalled()
        expect(foo.bar.calls.count()).toEqual(4)
        expect(foo.bar.calls.argsFor(0)).toEqual([0, 0])
        expect(foo.bar.calls.argsFor(1)).toEqual([1, 0])
        expect(foo.bar.calls.argsFor(2)).toEqual([0, 1])
        expect(foo.bar.calls.argsFor(3)).toEqual([1, 1])
        done()
      )

      forLoop.run()
      return

    it 'loop-control values in the group may initiate a countdown loop..', (done)->

      spyOn(foo, 'bar').and.callThrough()

      forLoop = CrunchTask.for([1, -1], [1, -1], foo.bar)

      expect(foo.bar).not.toHaveBeenCalled()

      forLoop.done( ()->
        expect(foo.bar).toHaveBeenCalled()
        expect(foo.bar.calls.count()).toEqual(4)
        expect(foo.bar.calls.argsFor(0)).toEqual([1, 1])
        expect(foo.bar.calls.argsFor(1)).toEqual([0, 1])
        expect(foo.bar.calls.argsFor(2)).toEqual([1, 0])
        expect(foo.bar.calls.argsFor(3)).toEqual([0, 0])
        done()
      )

      forLoop.run()
      return

    it 'if no function is supplied, the loop resolves automatically when started', (done)->
      spyOn(foo, 'bar').and.callThrough()
      forLoop = CrunchTask.for()
      forLoop.done(foo.bar)

      expect(foo.bar).not.toHaveBeenCalled()

      forLoop.run()

      setTimeout(()->
        expect(foo.bar).toHaveBeenCalled()
        done()
      , 1000)
      return

    it 'if a task is used in combination with the `for()` method as a body executable, onIdle is generated upon completion of the task, not the loop', (done)->

#      console.log "jasmine.DEFAULT_TIMEOUT_INTERVAL: #{jasmine.DEFAULT_TIMEOUT_INTERVAL}"

      waitSize = 33

      bodyTask = new CrunchTask (init, body)->
        countMemo = {
          count: waitSize
        }
        init (_x, _y)->
          return
        body (resolve)->
          do resolve unless countMemo.count--
        return

      timestamps = []

      forTaskEmpty = CrunchTask.for([0, waitSize], [0, waitSize], (x, y)-> x)
      forTaskLoaded = CrunchTask.for([0, waitSize], [0, waitSize], bodyTask)

      forTaskEmpty.onIdle ()->
        timestamps.push (new Date() - 0)


      bodyTask.onIdle ()->

      forTaskLoaded.onIdle ()->
        timestamps.push (new Date() - 0)
        expect(timestamps.length).toBe(3)
        expect(timestamps[2] > timestamps[1]).toEqual(true)
        expect(timestamps[1] > timestamps[0]).toEqual(true)
        expect((timestamps[2] - timestamps[1]) > (timestamps[1] - timestamps[0])).toEqual(true)

        done()
        return

#      console.log "Start"
      timestamps.push (new Date() - 0)
#      console.log JSON.stringify timestamps

      forTaskEmpty.run().then(()->
        forTaskLoaded.run()
        return
      )

      return

    return


  describe 'the `forEach()` method', ()->
    it 'enumerates a long array in async fashion', (done)->
      length = 50000
      count = 0
#      console.log new Date() - 0
      task = CrunchTask.forEach(new Array(length), (v, k)->
#        console.log new Date() - 0 unless k % 10000
        expect(type(v)).toBe('undefined')
        expect(k).toEqual(count)
        count++
      )
      task.run().always(()->
#        console.log new Date() - 0
        expect(count).toEqual(length)
        done()
      )
      return

    return

  describe 'the `reduce()` method', ()->
    beforeEach ()->
      CrunchTask.config(false)

    it 'enumerates a long array and collects data in async fashion', (done)->
      length = 45000
      count = 0
      memo = 0
#      console.log (global || window).agent
      CrunchTask.config({
        timeLimit: 150
      })
      task = CrunchTask.reduce(new Array(length), memo, (memo, v, k)->
        memo += k % 2
        expect(type(v)).toBe('undefined')
        expect(k).toEqual(count)
        count++
        memo
      ).done (memo)->
        expect(memo).toEqual(length / 2)
        done()
      task.run()
    return

  describe 'the `config()` method', ()->
    beforeEach ()->
      CrunchTask.config(false)

    it 'sets known global config parameters or resets the entire config file', ()->
      result1 = CrunchTask.config({
        timeLimit: 50
      });
      CrunchTask.for(0, 10, false, (n)->
        # will execute the for-loop with a limit of 50 seconds (to setTImeout again)
      )
      expect(result1.timeLimit).toEqual(50)
      expect(result1.timeoutAmount).toBeUndefined()
      expect(result1.debug).toBeUndefined()

      result2 = CrunchTask.config({
        timeoutAmount: 1000
      })
      CrunchTask.for(0, 10, false, (n)->
        # will execute the for-loop with a 1 second delay each
      )
      expect(result2.timeLimit).toBeUndefined()
      expect(result2.timeoutAmount).toEqual(1000)
      expect(result2.debug).toBeUndefined()


      result3 = CrunchTask.config({
        debug: true
      })
      expect(result3.timeLimit).toBeUndefined()
      expect(result3.timeoutAmount).toBeUndefined()
      expect(result3.debug).toEqual(true)

      result4 = CrunchTask.config({
        timeLimit: 0
        timeoutAmount: 2000
        debug: true
      })
      CrunchTask.for(0, 10, false, (n)->
        # will execute the for-loop with a 2 seconds delay each, + debug info into console
      )
      expect(result4.timeLimit).toEqual(0)
      expect(result4.timeoutAmount).toEqual(2000)
      expect(result4.debug).toEqual(true)


      result5 = CrunchTask.config(false) # resets back to normal

      expect(result5.timeLimit).toEqual(100)
      expect(result5.timeoutAmount).toEqual(0)
      expect(result5.debug).toEqual(false)


  return
