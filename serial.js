#!/usr/bin/env node
//var assert = require('assert');
var cradle = require('cradle');
var date = require('date-utils');  
var serialport = require("serialport");
var argv = require('optimist').argv;

var SerialPort = serialport.SerialPort;
var sp = new SerialPort("/dev/tty"+argv.sp, { 
  //parser: serialport.parsers.raw,
  parser: serialport.parsers.readline("\n"),
  baudrate: 9600
});

var db = new(cradle.Connection)().database('sensors_dirty');

var i = 0;  
var date_string = function date_string(){ return Date.today().toYMD("_") +"@" + (new Date()).getHours() + ":"+(new Date()).getMinutes()+ ":" + (new Date()).getSeconds()+"." + (new Date()).getMilliseconds() };

sp.on("data", function (data) {

  var handleSave = function(err, r) {
    return function (err, r) {
        if (argv.debug == 1) { console.log("DEBUG :: Saved to DB"); }
      if (err)  throw new Error(err);
    }
  }

  console.log("  "+data);
  var splitted1 = data.split("A:")

  if(splitted1[1]!=undefined){
    var splitted2 = splitted1[1].split(",T: "); 
    var splitted3 = splitted2[1].split("\r"); 
    var temp =  splitted3[0];          
    var address = splitted2[0];
    
    if (argv.debug == 1) {                   
      console.log("DEBUG :: Extracted :: Address: "+address+", Temperature: "+temp);
      console.log("DEBUG :: Saving to CouchDB ... ");
    }
      db.save(date_string()+ "@" + i, {
          time: new Date(),
          address: address, 
          name: (''),
          data: temp
      }, handleSave());
  
  }

  var enddata = data.search("ENDDATA");
  if (enddata != -1) {
    if (argv.debug == 1) { console.log("DEBUG :: ENDDATA reached , incrementing ..."); } 
    i++;
  }
});
