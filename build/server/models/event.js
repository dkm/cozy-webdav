// Generated by CoffeeScript 1.7.1
var Event, VAlarm, VCalendar, VEvent, VTodo, americano, moment, time, _ref;

americano = require('americano-cozy');

time = require('time');

moment = require('moment');

_ref = require('../lib/ical_helpers'), VCalendar = _ref.VCalendar, VTodo = _ref.VTodo, VAlarm = _ref.VAlarm, VEvent = _ref.VEvent;

module.exports = Event = americano.getModel('Event', {
  id: {
    type: String,
    "default": null
  },
  caldavuri: String,
  start: String,
  end: String,
  rrule: String,
  place: {
    type: String,
    "default": ''
  },
  description: {
    type: String,
    "default": ''
  },
  details: {
    type: String,
    "default": ''
  },
  diff: {
    type: Number,
    "default": 0
  },
  related: {
    type: String,
    "default": null
  }
});

require('cozy-ical').decorateEvent(Event);

Event.all = function(cb) {
  return Event.request('byURI', cb);
};

Event.byURI = function(uri, cb) {
  var req;
  req = Event.request('byURI', null, cb);
  req.body = JSON.stringify({
    key: uri
  });
  return req.setHeader('content-type', 'application/json');
};
