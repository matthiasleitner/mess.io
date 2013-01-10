redis      = require("redis")
inflection = require("inflection")

class RedisObject

  client = redis.createClient()
  
  constructor: (@obj) ->
    @id = obj.id
    @_ = @constructor
    @_.generateAssociationMethods()

  
  # Delete object from redis
  #
  #
  delete: (cb) ->
    console.log "delete user"
    client.DEL "#{@_.className()}|#{@id}", cb
    @removeAssociations()

  # Persist object
  #
  #
  save: (cb) ->
    console.log cb
    if @id == undefined
      @_nextId (id) =>
        @id = id
        @obj.createdAt = new Date()
        @save(cb)
    else
      @obj.updatedAt = new Date()
      
      client.HMSET "#{@_.className()}|#{@id}", @_.stringifyAttributes(@obj), (err, reply) =>  
        if !err
          @afterCreate cb
        else
          cb err, null
          console.log err

  toString: ->
    "ID: #{@id} - #{@name} - #{@createdAt} #{JSON.stringify(@obj)}"

  toJSON: ->
    JSON.stringify(@obj)

  afterCreate: (cb) ->
    console.log "stored #{@_.className()} with id: #{@id} "
    client.SADD "#{@_.className()}_ids", @id, (err, reply) =>
      cb err, @obj
      @_applyAssociations()

  # ---------------------------------------------------------
  # static methods
  # ---------------------------------------------------------

  @className: ->
    @.name.toLowerCase()

  @all: (cb) ->
    cN = @className()
    client.sort "#{cN}_ids", "by", "#{cN}|*->id", "get", "#{cN}|*->name","get", "#{cN}|*->id", redis.print
  
  @find: (id, cb) ->
    client.HGETALL "#{@className()}|#{id}", (err, obj) =>
      if obj
        obj.id = id
        cb null, new this(obj)
      else
        cb err, null

  @count: (cb) ->
    client.get "#{@className()}|count", cb

  @stringifyAttributes: (obj) ->
    sObj = {}
    for k,v of obj      
      sObj[k] = "#{v}"
    sObj

  @generateAssociationMethods: ->
    if @hasMany
      for assoc in @hasMany
        do (assoc) =>
          unless @::[assoc]
            @::[assoc] = (cb) ->
              unless @id == undefined
                cN = inflection.singularize assoc
                client.sort "#{assoc}_for_#{@_.className()}|#{@id}", "get", "#{cN}|*->createdAt", cb
    if @belongsTo
      for assoc in @belongsTo
        do (assoc) =>
          unless @::[assoc] 
            @::[assoc] = (cb) ->
              assocKey = "#{assoc}Id"
              if @obj[assocKey]
                client.HGETALL "#{assoc}|#{@obj[assocKey]}", cb
                
                  
            
          

  # ---------------------------------------------------------
  # private methods
  # ---------------------------------------------------------

  _assocKey: (assoc) ->
    cN = inflection.pluralize @_.className()
    assocId = @obj["#{assoc}Id"]
    "#{cN}_for_#{assoc}|#{assocId}"

  _nextId: (cb) ->
    client.INCR "#{@_.className()}|count", (err, val) =>
      cb(val)

  _applyAssociations: (cb) ->
    @_handleAssociations cb
  
  _removeAssociations: (cb) ->  
    @_handleAssociations cb, "remove"

  _handleAssociations: (cb, mode = "add") ->
    if @_.belongsTo
      for assoc in @_.belongsTo
        do (assoc) ->
          if @id && @obj["#{assoc}Id"]
            switch mode
              when "add" then 
                client.SADD @_assocKey(assoc), @id, cb
              when "remove" then 
                client.SREM @_assocKey(assoc), @id, cb
                

module.exports = RedisObject