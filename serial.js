  var serialport = require("serialport");
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

    if(splitted1[1]!=undefined)
      {
            var splitted2 = splitted1[1].split(",T: ");
            var temp = splitted2[1].split("\r");            
var address = splitted2[0];
                       
console.log("DEBUG :: Extracted :: Address: "+address+", Temperature: "+temp);
  
      }
  });
