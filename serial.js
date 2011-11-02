#!/usr/bin/env node
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

var connection = new(cradle.Connection)('http://127.0.0.1', 5984, {
  cache: false,
  raw: false
});
var db = connection.database('sensors_dirty');

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
    var name = "";

    switch(address){
      case "286C5A1E03000041":
        name = "air_in"
      break;
      case "28257E1E03000045":
        name = "room1"
      break;
      case "28B5501E030000AE":
        name = "room2"
      break;
      case "28617C1E0300006F":
        name = "crix1"
      break;
      case "28F8441E030000F2":
        name = "crix2"
      break;
      case "285D5F1E03000049":
        name = "crix3"
      break;
      default:
        name = ""
    }
    
    if (argv.debug == 1) {                   
      console.log("DEBUG :: Extracted :: Address: "+address+", Temperature: "+temp);
      console.log("DEBUG :: Saving to CouchDB ... ");
    }
      db.save(date_string()+ "@" + i, {
          time: new Date(),
          address: address, 
          name: name,
          data: temp
      }, handleSave());
  
  }

  var enddata = data.search("ENDDATA");
  if (enddata != -1) {
    if (argv.debug == 1) { console.log("DEBUG :: ENDDATA reached , incrementing ..."); } 
    i++;
  }
});
