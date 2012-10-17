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

do (jQuery = $, window = window) ->

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
      @startdate  = new Date()
      @enddate    = settings.enddate
      @remaining  = {}

      ###
       * To account for leap years, February is set as a function that
       * will take into account if the next February from the current date
       * has a bonus day. ###

      units       =
        seconds : 60
        minutes : 60
        hours   : 24
        days    : [
                    31, ( =>
                      d = new Date @startdate.getFullYear() + (if @startdate.getMonth() >= 2 then 1 else 0), 2, 0
                      d.getDate()
                    )(), 31, 30,
                    31, 30, 31, 31,
                    30, 31, 30, 31
                  ]
        weeks   : 7
        months  : 12
        years   : 365




      ###
      # console.log cleanArray settings.values, units
      
      for unit of units
        value = units[unit]
        if !!value and $.inArray(unit, settings.values) isnt -1
          console.log unit, value
      ###



      ###
       * difference between two dates in seconds ###

      seconds  = Math.floor (@enddate - @startdate) / 1000

      ###
       * Set the remaining seconds by checking how many
       * seconds remain with the removal of minutes.
       * Then find the remaining minutes by dividing by 60 seconds,
       * and rounding down to a whole number. ###

      @remaining.seconds = seconds % units.seconds

      minutes = Math.floor seconds / units.seconds

      ###
       * Repeat for minutes. ###

      @remaining.minutes = minutes % units.minutes

      hours = Math.floor minutes / units.minutes

      ###
       * Repeat for hours. ###

      @remaining.hours = hours % units.hours

      ###
       * Find total number of days.
       * We will use this number to extract months and years. ###

      days = Math.floor hours / units.hours

      ###
       * Remove the number of full years ###

      @remaining.years = Math.floor days / units.years

      ###
       * Reassign days with only the remainding after removing years. ###

      days = days % units.years

      ###
       * Set the starting positions for the countdown. ###

      months  = 0
      current = @startdate.getMonth()
      monthLength = units.days[current]

      ###
       * Create an IIFE that will call itsself until it has less days
       * remaining than days in the month it's checking for. ###

      monthSetter = =>
        if (days >= monthLength)
          days = days - monthLength
          months  = months + 1
          current = current + 1
          monthLength = units.days[current]
          monthSetter()
        else 
          @remaining.months = months
          @remaining.days = days
      monthSetter()

      # @element.trigger "updateTime"

      @timer = new Timer =>
        @element.trigger "updateTime", @remaining

      # @timer.start()

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
    enddate : new Date "11:59 PM Dec 31 2012 CST"
    values  : ["years", "months", "weeks", "days", "seconds", "hours"]

  $("#countdown")[name]().on "updateTime", (e, params) ->
      console.log "updateTime", params
      
