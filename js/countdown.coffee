###
 *
 * JavaScript plugin to calculate the time remaining between two
 * dates in common units of time.
 *
 *
 * Settings are able to be passed into the Countdown object both
 * globally through the 'defaults' object like:
 *
 *   $.fn.countdown.defaults = {
 *     example: 'data'
 *   };
 *
 *
 * or through the data attached on an element like:
 *
 *   <div id="countdown" data-example="data"></div>
 *
 *
 * Note:  If values are set in both places, then the information
 *        set on the element will override the settings in the
 *        'defaults' object
 *
 *
 * Several units of time can be returned. The values you need returned
 * should be passed to the settings in an array named 'values' like:
 *
 *   $.fn.countdown.defaults = {
 *     values  : ["years", "months", "weeks", "days", "hours", "minutes", "seconds"]
 *   };
 *
 *
###

do ($ = jQuery, window = window) ->

  console     = window.console
  name        = "countdown"

  class Timer
    constructor : (@tick) ->
      @interval   =   1000
      @enable     =   false
      @timerId    =   0

    start       : ->
      @enable     =   true
      fn = =>
        if @enable then @tick()
      @timerId    =   setInterval fn, @interval

    stop        : ->
      @enable     =   false
      clearInterval @timerId

  class Countdown
    constructor : (@element, settings) ->

      _tick = =>
        @count settings
        @element.trigger "updateTime", @remaining

      @timer = new Timer =>
        _tick()

      _tick()
      @timer.start()

    count       : (settings) ->
      @startdate  = new Date()
      @enddate    = new Date settings.enddate
      @remaining  = {}

      ###
       * To account for leap years, February is set as a function that
       * will take check if the next February from the current date
       * has a bonus day. ###

      units       =
        seconds : 1
        minutes : 60
        hours   : 60 * 60
        days    : 24 * 60 * 60
        weeks   : 7 * 24 * 60 * 60
        months  : (value * 24 * 60 * 60 for value in [
                                                        31, ( =>
                                                          d = new Date @startdate.getFullYear() + (if @startdate.getMonth() >= 2 then 1 else 0), 2, 0
                                                          d.getDate()
                                                        )(), 31, 30,
                                                        31, 30, 31, 31,
                                                        30, 31, 30, 31
                                                      ]
                  )
        years   : 365 * 24 * 60 * 60

      ###
       * Set the difference between two dates in seconds.
       *
       * This value will be continually subtracted from.
       * Using this method, we can take the difference in days
       * from month to month as well as leap years. ###

      seconds  = Math.floor (@enddate - @startdate) / 1000

      ###
       * Create a blank ojbect that will hold all of our return values
       *
       * Loop through the values, checking that an equivilant value
       * exists in the 'units' object and insert them into the
       * 'this.remaining'. ###

      @remaining = {}

      for unit of units 
        value = units[unit]
        if !!value and $.inArray(unit, settings.values) isnt -1
          @remaining[unit] = true

      ###
       * Loop through the years between now and then.
       * Looping rather than just checking static years allows
       * for leap years to be accounted for and not mess up the
       * count of days between dates. ###


      if @remaining.years
        _years       = 0
        _month       = @startdate.getMonth()
        _current     = @startdate.getFullYear() + (if _month > 1 then + 1 else 0)
        _yearLength  = units.years + (if new Date(_current, 2, 0).getDate() > 28 then units.days else 0)

        ###
         * Create an IIFE that will call itsself until it has less days
         * remaining than days in the year it's checking for. ###

        yearSetter = =>
          if seconds >= _yearLength
            seconds = seconds - _yearLength
            _years = _years + 1
            _current = _current + 1
            _yearLength  = units.years + (if new Date(_current, 2, 0).getDate() > 28 then units.days else 0)
            yearSetter()
          else
            @remaining.years = _years
        yearSetter()

      ###
       * Loop through the months between now and then.
       * Looping in this manner allows checking for different
       * length months without removing or not removing the
       * right amout of time from our count. ###

      if @remaining.months
        _months      = 0
        _current     = @startdate.getMonth()
        _monthLength = units.months[_current]

        ###
         * Create an IIFE that will call itsself until it has less days
         * remaining than days in the month it's checking for. ###

        monthSetter = =>
          if (seconds >= _monthLength)
            seconds   = seconds - _monthLength
            _months   = _months + 1
            _current  = _current + 1
            if _current is 12 then _current = 0
            _monthLength = units.months[_current]
            monthSetter()
          else 
            @remaining.months = _months
        monthSetter()


      ###
       * Since the last units of time (minutes, hours, days, weeks)
       * don't change their length, we can loop through these
       * rather than code another if block for each. ###

      for unit in ["weeks", "days", "hours", "minutes"]
        if @remaining[unit]
          @remaining[unit] = Math.floor seconds / units[unit]
          seconds = seconds % units[unit]

      ###
       * Finally, set the seconds remaining. ###

      if @remaining.seconds then @remaining.seconds = seconds

  ###
   *
   * Attach the class to the jQuery object
   *
  ###

  $.fn[name] = (params) ->
    $(this).each ->
      $this = $ this
      data  = if $this.data(name) then $this.data(name) else (-> 
                $this.data name, new Countdown $this, $.extend true, {}, $.fn[name].defaults, $this.data()
                $this.data name
              )()

      if !!params and typeof params is "string" then data[params]? data[params]()

  ###
   *
   * Set the defaults
   *
  ###

  $.fn[name].defaults =
    enddate : "12:59 AM Dec 31 2012 CST"
    values  : ["days", "minutes", "seconds", "hours"]
