  var serialport = require("serialport");
  var SerialPort = serialport.SerialPort;
  var sp = new SerialPort("/dev/tty"+process.argv.splice(2), { 
      //parser: serialport.parsers.raw,
      parser: serialport.parsers.readline("\n"),
      baudrate: 9600
  });
  
  sp.on("data", function (data) {
    console.log("::"+data);
  });
