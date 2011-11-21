#!/usr/bin/env node
var cradle = require('cradle');
var date = require('date-utils');  
var serialport = require("serialport");
var argv = require('optimist').argv;
var CONFIG = require('config').couch;

var SerialPort = serialport.SerialPort;
var sp = new SerialPort("/dev/tty"+argv.sp, { 
  //parser: serialport.parsers.raw,
  parser: serialport.parsers.readline("\n"),
  baudrate: 9600
});

var connection = new(cradle.Connection)(CONFIG.dbHost, CONFIG.dbPort, {
  cache: false,
  raw: false
});
var db = connection.database(CONFIG.dbName);

var i = 0;  
var date_string = function date_string(){ return Date.today().toYMD("_") +"@" + (new Date()).getHours() + ":"+(new Date()).getMinutes()+ ":" + (new Date()).getSeconds()+"." + (new Date()).getMilliseconds() };

var sensors = [];
var counter=0;

sp.on("data", function (data) {

  var handleSave = function(err, r) {
    return function (err, r) {
        if (argv.debug == 1) { console.log("DEBUG :: Saved to DB"); }
      if (err)  throw new Error(err);
    }
  }
  
  console.log("  "+data);
  var begin_data = data.search("DATA");
  
  if (begin_data != -1) {

   }
   
  var splitted1 = data.split("A:")
  if(splitted1[1]!=undefined){
    if(splitted1[1].search(",T: ") != -1) {var splitted2 = splitted1[1].split(",T: "); } else {var splitted2 = splitted1[1].split(",H: "); }
    //var splitted2 = splitted1[1].split(",T: "); 
    var splitted3 = splitted2[1].split("\r"); 
    var sensor_data =  splitted3[0];  
    console.log('sensor_data: '+sensor_data);        
    var address = splitted2[0];
    var name = "";



    switch(address){
      case "room1_DHT_temp":
        name = "room1_DHT_temp"     
      break;
      case "room1_DHT_hum":
        name = "room1_DHT_hum"
      break;

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
    
    var sensor_obj = {data: sensor_data, address: address, name: name};
    //sensor_obj.data = sensor_data;
    sensors.push(sensor_obj);
   

    
  }
  

  var enddata = data.search("ENDDATA");
  if (enddata != -1) {
    console.log('size'+sensors.length);
    for(var i=0; i<sensors.length; i++) {
      console.log(sensors[i].data);
    }


    db.save(date_string()+ "@" + i, {
      time: new Date().getTime(),
      sensors: sensors
       
    }, handleSave());
  
   if (argv.debug == 1) {
     console.log("DEBUG :: Extracted :: Address: "+address+", Temperature: "+sensor_data);
     console.log("DEBUG :: Saving to CouchDB ... ");
     console.log("DEBUG :: ENDDATA reached , incrementing ...");
   } 
    console.log("DEBUG :: sensors_length before : "+sensors.length);
    console.log("DEBUG :: DATA : counter : "+counter+"  Cleaning array...");
    sensors.splice(sensors.length-counter,counter);
    console.log("DEBUG :: sensors_length after: "+sensors.length);

    
    i++;
        counter = 0;
  }
  
  if(data.search("A:")!=-1){counter++}; 
});
