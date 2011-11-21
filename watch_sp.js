#!/usr/bin/env node 
var serialport = require("serialport")
    ,argv = require('optimist').argv;


var SerialPort = serialport.SerialPort;
var sp = new SerialPort("/dev/tty"+argv.sp, { 
  parser: serialport.parsers.readline("\n"),
  baudrate: 9600
});

sp.on("data", function (data) {
	console.log("  "+data);
});
