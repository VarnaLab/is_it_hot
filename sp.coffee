#!/usr/bin/env node
cradle = require 'cradle'
date = require 'date-utils'
serialport = require "serialport"
argv = require('optimist').argv
couchdb = require('config').couchdb
time_data = require(__dirname + '/helpers/time.coffee').time_data
serial_parser = require(__dirname + '/helpers/serial_parser.coffee')
db_helper = require(__dirname + '/helpers/db_helper.coffee')

console.log "DEBUG :: On" if argv.debug

SerialPort = serialport.SerialPort
serial_port = new SerialPort "/dev/tty" + argv.sp, { 
  parser: serialport.parsers.readline("\n"), 
  baudrate: 9600 
}

connection = new(cradle.Connection)(couchdb.host, couchdb.port, { cache: false, raw: false })
db = connection.database(couchdb.name)

i = 0
counter = 0

serial_port.on "data", (data) ->
  console.log  data 
  data_tag = data.search "<"
  data_end = data.search "ENDDATA"
 
  unless data_tag is -1
    serial_parser.parse data

  unless data_end is -1
    
    db.save(time_data(i).time_str, { 
      time: new Date().getTime(),
      time_arr: time_data(i).time_arr,
      sensors: sensors
    }, db_helper.output()) if db
  
    console.log "DEBUG :: Extracted :: " + JSON.stringify(sensors) if argv.debug 
    
    sensors = []
    i++
    counter = 0 
  unless data.search "<" is -1
    counter++
