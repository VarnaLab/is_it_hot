#!/usr/bin/env node
serialport = require "serialport"
argv = require('optimist').argv
date = require 'date-utils'
time_helper = require(__dirname + '/helpers/time.coffee')
serial = require(__dirname + '/helpers/serial.coffee')
couchdb = require(__dirname + '/helpers/couchdb.coffee')

if argv.list
  serial.list
else
  console.log "DEBUG :: On" if argv.debug

  SerialPort = serialport.SerialPort
  serial_port = new SerialPort "/dev/tty" + argv.sp, { 
    parser: serialport.parsers.readline("\n"), 
    baudrate: 9600 
  }

  i = 0
  counter = 0
  sensors = []

  serial_port.on "data", (data) ->
    console.log  data 
    data_tag = data.search "<"
    data_end = data.search "ENDDATA"
   
    unless data_tag is -1
      counter++
      sensors.push serial.parse(data)

    unless data_end is -1
      console.log "DEBUG :: Extracted :: " + JSON.stringify(sensors) if argv.debug 

      time_str = time_helper.time_data(i).time_str
      time_arr = time_helper.time_data(i).time_arr
      
      couchdb.save(time_str, time_arr, sensors)

      counter = 0
      sensors = []
      i++ 