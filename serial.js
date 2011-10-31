//var assert = require('assert');
var cradle = require('cradle');
var date = require('date-utils');  
var serialport = require("serialport");

var db = new(cradle.Connection)().database('sensors_dirty');
var date_string = function date_string(){ return Date.today().toYMD("_") +"@" + (new Date()).getHours() + ":"+(new Date()).getMinutes()+ ":" + (new Date()).getSeconds()+"." + (new Date()).getMilliseconds() };

var handleSave = function(err, r) {
  return function (err, r) {
    console.log("DEBUG :: Saved to DB");
    if (err)  throw new Error(err);
  }
}

var SerialPort = serialport.SerialPort;
var sp = new SerialPort("/dev/tty"+process.argv.splice(2), { 
  //parser: serialport.parsers.raw,
  parser: serialport.parsers.readline("\n"),
  baudrate: 9600
});
  
sp.on("data", function (data) {
  console.log("::"+data);
  //console.log(data.split("DATA"));
  var splitted1 = data.split("A:")

  if(splitted1[1]!=undefined){
    var splitted2 = splitted1[1].split(",T: ");
    var temp = splitted2[1].split("\r");            
    var address = splitted2[0];
                        
    console.log("DEBUG :: Extracted :: Address: "+address+", Temperature: "+temp);
    console.log("DEBUG :: Saving to CouchDB ... ");
      db.save(date_string()+ "@" + i, {
          time: new Date(),
          address: addresss, 
          name: (''),
          data: temp
      }, handleSave());
  
  }
});
