redis      = require("redis")
inflection = require("inflection")
bases      = require("bases")
crypto     = require("crypto")
_          = require("underscore")
Benchmark  = require('benchmark')

class RedisObject


  script = """
          -- fetch all assoc ids
          local ids = redis.call("ZRANGE", ARGV[2], 0, -1)
            
          local result = {}
          local hashValue = nil

          -- generate correct namespace
          local namespace = ARGV[1].."|"

          for i,v in ipairs(ids) do
            hashValue = redis.call("HGETALL", namespace..v)
            table.insert(hashValue, "id")
            table.insert(hashValue, v)
            result[i] = hashValue
          end
          return result
         """

  db = redis.createClient()
  klass = null

  constructor: (@obj) ->
    @id = obj.id
    klass = @constructor
    klass._generateAssociationMethods()

  
  # Delete object from redis
  #
  #
  delete: (cb) ->
    console.log "delete #{klass._name()} with id: #{@id}"

    # delete actual object hash
    db.DEL @_dbKey(),(err, reply) =>  
      # delete from class index
      db.ZREM klass._indexKey(), @id, cb
      
    @_removeAssociations()

  # Persist object
  #
  #
  save: (cb) ->    
    # new object
    if @id == undefined
      @_nextId (id) =>
        @id = id
        @obj.createdAt = new Date()

        # once ID is fetched call save again 
        @save(cb)
    else
      @obj.updatedAt = new Date()
      
      db.HMSET @_dbKey(), klass.stringifyAttributes(@obj), (err, reply) =>  
        if !err
          @_afterCreate cb
        else
          cb err, null          

  toString: ->
    JSON.stringify(@obj)

  toJSON: ->
    @obj

  
  # ---------------------------------------------------------
  # static methods
  # ---------------------------------------------------------

  @create: (obj, cb) ->
    new this(obj).save(cb)

  @all: (cb) ->
    db.eval script, 0, @_name(), @_indexKey(), (err, reply) =>
      cb err, @_arrayReplyToObjects(reply)

    #cN = @_name()        
    #db.sort "#{cN}_ids", "by", "#{cN}|*->id", "get", "#{cN}|*->name", "get", "#{cN}|*->createdAt","get", "#{cN}|*->updatedAt", (err, reply) =>


  @find: (id, cb) ->
    db.HGETALL @_dbKey(id), (err, obj) =>
      if obj
        obj.id = id
        cb null, new this(obj)
      else
        cb err, null

  @count: (cb) ->
    db.get @_countKey(), cb

  # Convert attributes of object to be stored as redis hash
  #
  #
  @stringifyAttributes: (obj) ->
    sObj = {}
    for k,v of obj      
      sObj[k] = "#{v}"
    sObj

  # Generate random Base62 key
  #
  #
  @generateKey: (length = 32) ->
  
    maxNum = Math.pow(62, length)
    numBytes = Math.ceil(Math.log(maxNum) / Math.log(256))

    loop
      bytes = crypto.randomBytes(numBytes)
      num = 0
      i = 0

      while i < bytes.length
        num += Math.pow(256, i) * bytes[i]
        i++
      break unless num >= maxNum

    bases.toBase62 num
                
  
  # ---------------------------------------------------------
  # private methods
  # ---------------------------------------------------------

  _assocKey: (assoc) ->
    cN = inflection.pluralize klass._name()
    assocId = @obj["#{assoc}Id"]
    "#{cN}_for_#{assoc}|#{assocId}"

  _hasManyKey: (assoc)->
    "#{assoc}_for_#{klass._name()}|#{@id}"


  _nextId: (cb) ->
    db.INCR "#{klass._name()}|count", (err, val) =>
      cb(val)

  _afterCreate: (cb) ->
    console.log "stored #{klass._name()} with id: #{@id} "
    db.ZADD klass._indexKey(), @id, @id, (err, reply) =>
      @obj.id = @id
      cb err, @obj
      @_applyAssociations()

  _applyAssociations: (cb) ->
    @_handleAssociations cb, "add"
  
  _removeAssociations: (cb) ->  
    @_handleAssociations cb, "remove"

  _handleAssociations: (cb, mode) ->
    if klass.belongsTo
      for assoc in klass.belongsTo
        do (assoc) =>
          if @id && @obj["#{assoc}Id"]
            if mode == "add"
              db.ZADD @_assocKey(assoc), @id, @id, cb
            else
              db.ZREM @_assocKey(assoc), @id, cb

  _dbKey: ->
    klass._dbKey @id

  @_generateAssociationMethods: ->
    if @hasMany
      for assoc in @hasMany
        do (assoc) =>
          unless @::[assoc]
            @::[assoc] = (cb) ->
              unless @id == undefined
                cN = inflection.singularize assoc
                db.eval script, 0, cN, @_hasManyKey(assoc), (err, reply) =>
                  
                  cb err, klass._arrayReplyToObjects(reply)
          
                #db.sort @_hasManyKey(assoc), "get", "#{cN}|*->createdAt", cb
    if @belongsTo
      for assoc in @belongsTo
        do (assoc) =>
          unless @::[assoc] 
            @::[assoc] = (cb) ->
              assocKey = "#{assoc}Id"
              if @obj[assocKey]
                require("./#{assoc}").find(@obj[assocKey], cb)

                #db.HGETALL "#{assoc}|#{@obj[assocKey]}", cb

  @_arrayReplyToObjects: (reply) ->
    # map array of redis replies to objects
      if reply
        reply = reply.map (obj)->
          db.reply_to_object(obj)

      reply
          

  @_name: ->
    @.name.toLowerCase()
    
  @_dbKey: (id) ->
    "#{@_name()}|#{id}"

  @_countKey: (id) ->
    "#{@_name()}|count"

  @_indexKey: ->
    "#{@_name()}_ids"
                


module.exports = RedisObject