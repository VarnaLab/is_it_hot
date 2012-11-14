couchdb = require('config').couchdb
cradle = require 'cradle'

connection = new(cradle.Connection)(couchdb.host, couchdb.port, { cache: false, raw: false })
db = connection.database(couchdb.name)

module.exports.save = save = (time_str, time_arr, sensors) ->
	db.save(time_str, { 
      time: new Date().getTime(),
      time_arr: time_arr,
      sensors: sensors
    }, output()) if db

output = (err, r) ->
  return (err, r) ->
      console.log "Saved to DB"
    if err 
      throw new Error(err)