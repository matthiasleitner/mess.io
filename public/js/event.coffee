root = exports ? this

class root.EventEmitter
  
  on: (event, cb) ->
    if typeof(cb) == 'function'
      @_handlers()
      unless @handlers[event]
        @handlers[event] = [] 
      @handlers[event].push cb
      true
    else
      false
 
  unbind: (event, cb) ->
    return false unless @handlers
    if @handlers[event]? && @handlers[event].indexOf(cb) >= 0
      @handlers[event].splice @handlers[event].indexOf(cb), 1
      true
    else
      false
      
  unbindAll: ->
    @handlers = {}
    true
 
  emit: (event, data={}) ->
    @_handlers()
    if @handlers[event]? && @handlers[event].length > 0
      for cb in @handlers[event]
        if typeof(cb) == 'function'
          cb(data) 
      true
    else
      false

  _handlers: ->
    @handlers = {} unless @handlers
 