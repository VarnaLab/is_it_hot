#!/usr/bin/env node
serialport = require "serialport"
argv = require('optimist').argv
date = require 'date-utils'
config = require 'config'
time_helper = require(__dirname + '/helpers/time.coffee')
serial = require(__dirname + '/helpers/serial.coffee')
couchdb = require(__dirname + '/helpers/couchdb.coffee')
cosm = require(__dirname + '/helpers/cosm.coffee')

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
  cosm_sensors = []

  serial_port.on "data", (data) ->
    console.log  data 
    data_tag = data.search "<"
    data_end = data.search "ENDDATA"
   
    unless data_tag is -1
      counter++
      sensor_obj = serial.parse(data)

      cosm_obj = {
        "current_value" : sensor_obj.data,
        "id" : sensor_obj.sn
      }

      cosm_sensors.push cosm_obj 
      sensors.push sensor_obj

    unless data_end is -1
      cosm_data = { "datastreams" : cosm_sensors }
      
      if argv.debug
        console.log "DEBUG :: Serial DATA :: " + JSON.stringify(sensors)
        console.log "DEBUG :: Cosm DATA :: " + JSON.stringify(cosm)

      time_str = time_helper.time_data(i).time_str
      time_arr = time_helper.time_data(i).time_arr
      
      #save to couchdb
      couchdb.save(time_str, time_arr, sensors)
     
      #send to cosm.com
      cosm.put(cosm_data)

      counter = 0
      sensors = []
      cosm_sensors = []
      i++ 