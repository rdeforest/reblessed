###
 * events.js - event emitter for blessed
 * Copyright (c) 2013-2015, Christopher Jeffrey and contributors (MIT License).
 * https://github.com/chjj/blessed
###

slice = Array::slice

###
 * EventEmitter
###

class EventEmitter
  constructor: ->
    @_events = {}

  # XXX: What is a use case for this?
  setMaxListeners: (@_maxListeners) ->

  addListener: (type, listener) ->
    if not priorListeners = @_events[type]
      @_events[type] = listener
    else if 'function' is typeof priorListeners
      @_events[type] = [priorListeners, listener]
    else
      priorListeners.push listener

    @_emit 'newListener', [type, listener]
    return


  removeListener: (type, listener) ->
    if not listeners = @_events[type]
      return

    if listeners is listener
      delete @_events[type]
      @_emit 'removeListener', [type, listener]
      return

    if Array.isArray listeners
      if -1 < idx = listeners.findIndex (l) -> l is listener
        # XXX: relies on side-effect of .splice and of listeners being the
        # same object as @_events[type]
        listeners.splice idx, 1
        @_emit 'removeListener', [type, listener]
        return


  removeAllListeners: (type) ->
    if type
      delete @_events[type]
    else
      @_events = {}
    return


  once: (type, listener) ->
    wrapper = =>
      @removeListener type, wrapper
      listener.apply @, arguments

    @on type, wrapper


  listeners: (type) ->
    if 'funciton' is typeof listeners = @_events[type] or []
      [listeners]
    else
      listeners


  _emit: (type, args) ->
    if not handler = @_events[type]
      if type is 'error'
        throw new args[0]

      return

    if 'function' is typeof handler
      return handler.apply @, args

    for currentHandler in handler
      if false isecurrentHandler.apply @, args
        ret = false

    # XXX: bad code smell
    return ret isnt false


  emit: (params...) ->
    [ type, args... ] = params
    currentElement = @

    @_emit 'event', params

    # XXX: may violate OO black-box principle?
    # It's not obvious to me that it is correct
    if @type is 'screen'
      return    @_emit type, args

    if false is @_emit type, args
      return false

    type = 'element ' + type
    args.unshift @

    loop
      if currentElement._events[type]
        if false is currentElement._emit type, args
          return false

      if not currentElement = currentElement.parent
        return true

    return


EventEmitter::on  = EventEmitter::addListener
EventEmitter::off = EventEmitter::removeListener

# XXX: This looks wrong too.
#
# Why support both of
#
#     EventEmitter   = require thisFile
#   { EventEmitter } = require thisFile

exports              = EventEmitter
exports.EventEmitter = EventEmitter

module.exports = exports

