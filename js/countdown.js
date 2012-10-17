// Generated by CoffeeScript 1.3.3

/*
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
*/


(function() {

  (function($, window) {
    var Countdown, Timer, console, name;
    console = window.console;
    name = "countdown";
    Timer = (function() {

      function Timer(tick) {
        this.tick = tick;
        this.interval = 1000;
        this.enable = false;
        this.timerId = 0;
      }

      Timer.prototype.start = function() {
        var fn,
          _this = this;
        this.enable = true;
        fn = function() {
          if (_this.enable) {
            return _this.tick();
          }
        };
        return this.timerId = setInterval(fn, this.interval);
      };

      Timer.prototype.stop = function() {
        this.enable = false;
        return clearInterval(this.timerId);
      };

      return Timer;

    })();
    Countdown = (function() {

      function Countdown(element, settings) {
        var _tick,
          _this = this;
        this.element = element;
        _tick = function() {
          _this.count(settings);
          return _this.element.trigger("updateTime", _this.remaining);
        };
        this.timer = new Timer(function() {
          return _tick();
        });
        _tick();
        this.timer.start();
      }

      Countdown.prototype.count = function(settings) {
        var monthSetter, seconds, unit, units, value, yearSetter, _current, _i, _len, _month, _monthLength, _months, _ref, _yearLength, _years,
          _this = this;
        this.startdate = new Date();
        this.enddate = settings.enddate;
        this.remaining = {};
        /*
               * To account for leap years, February is set as a function that
               * will take check if the next February from the current date
               * has a bonus day.
        */

        units = {
          seconds: 1,
          minutes: 60,
          hours: 60 * 60,
          days: 24 * 60 * 60,
          weeks: 7 * 24 * 60 * 60,
          months: (function() {
            var _i, _len, _ref, _results,
              _this = this;
            _ref = [
              31, (function() {
                var d;
                d = new Date(_this.startdate.getFullYear() + (_this.startdate.getMonth() >= 2 ? 1 : 0), 2, 0);
                return d.getDate();
              })(), 31, 30, 31, 30, 31, 31, 30, 31, 30, 31
            ];
            _results = [];
            for (_i = 0, _len = _ref.length; _i < _len; _i++) {
              value = _ref[_i];
              _results.push(value * 24 * 60 * 60);
            }
            return _results;
          }).call(this),
          years: 365 * 24 * 60 * 60
        };
        /*
               * Set the difference between two dates in seconds.
               *
               * This value will be continually subtracted from.
               * Using this method, we can take the difference in days
               * from month to month as well as leap years.
        */

        seconds = Math.floor((this.enddate - this.startdate) / 1000);
        /*
               * Create a blank ojbect that will hold all of our return values
               *
               * Loop through the values, checking that an equivilant value
               * exists in the 'units' object and insert them into the
               * 'this.remaining'.
        */

        this.remaining = {};
        for (unit in units) {
          value = units[unit];
          if (!!value && $.inArray(unit, settings.values) !== -1) {
            this.remaining[unit] = true;
          }
        }
        /*
               * Loop through the years between now and then.
               * Looping rather than just checking static years allows
               * for leap years to be accounted for and not mess up the
               * count of days between dates.
        */

        if (this.remaining.years) {
          _years = 0;
          _month = this.startdate.getMonth();
          _current = this.startdate.getFullYear() + (_month > 1 ? +1 : 0);
          _yearLength = units.years + (new Date(_current, 2, 0).getDate() > 28 ? units.days : 0);
          /*
                   * Create an IIFE that will call itsself until it has less days
                   * remaining than days in the year it's checking for.
          */

          yearSetter = function() {
            if (seconds >= _yearLength) {
              seconds = seconds - _yearLength;
              _years = _years + 1;
              _current = _current + 1;
              _yearLength = units.years + (new Date(_current, 2, 0).getDate() > 28 ? units.days : 0);
              return yearSetter();
            } else {
              return _this.remaining.years = _years;
            }
          };
          yearSetter();
        }
        /*
               * Loop through the months between now and then.
               * Looping in this manner allows checking for different
               * length months without removing or not removing the
               * right amout of time from our count.
        */

        if (this.remaining.months) {
          _months = 0;
          _current = this.startdate.getMonth();
          _monthLength = units.months[_current];
          /*
                   * Create an IIFE that will call itsself until it has less days
                   * remaining than days in the month it's checking for.
          */

          monthSetter = function() {
            if (seconds >= _monthLength) {
              seconds = seconds - _monthLength;
              _months = _months + 1;
              _current = _current + 1;
              if (_current === 12) {
                _current = 0;
              }
              _monthLength = units.months[_current];
              return monthSetter();
            } else {
              return _this.remaining.months = _months;
            }
          };
          monthSetter();
        }
        /*
               * Since the last units of time (minutes, hours, days, weeks)
               * don't change their length, we can loop through these
               * rather than code another if block for each.
        */

        _ref = ["weeks", "days", "hours", "minutes"];
        for (_i = 0, _len = _ref.length; _i < _len; _i++) {
          unit = _ref[_i];
          if (this.remaining[unit]) {
            this.remaining[unit] = Math.floor(seconds / units[unit]);
            seconds = seconds % units[unit];
          }
        }
        /*
               * Finally, set the seconds remaining.
        */

        if (this.remaining.seconds) {
          return this.remaining.seconds = seconds;
        }
      };

      return Countdown;

    })();
    /*
       *
       * Attach the class to the jQuery object
       *
    */

    $.fn[name] = function(params) {
      return $(this).each(function() {
        var $this, data;
        $this = $(this);
        data = $this.data(name) ? $this.data(name) : (function() {
          $this.data(name, new Countdown($this, $.extend(true, {}, $.fn[name].defaults, $this.data())));
          return $this.data(name);
        })();
        if (!!params && typeof params === "string") {
          return typeof data[params] === "function" ? data[params](data[params]()) : void 0;
        }
      });
    };
    /*
       *
       * Set the defaults
       *
    */

    $.fn[name].defaults = {
      enddate: new Date("12:59 AM Dec 31 2012 CST"),
      values: ["days", "minutes", "seconds", "hours"]
    };
    return $("#countdown").on("updateTime", function(e, params) {
      var k, v, _results;
      _results = [];
      for (k in params) {
        v = params[k];
        _results.push(console.log(k, v));
      }
      return _results;
    })[name]();
  })(jQuery, window);

}).call(this);
