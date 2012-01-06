(function() {
  var CONFIG, SerialPort, argv, connection, counter, cradle, date, db, i, sensors, serialport, sp, time_data;

  cradle = require('cradle');

  date = require('date-utils');

  serialport = require("serialport");

  argv = require('optimist').argv;

  CONFIG = require('config').couch;

  if (argv.debug) console.log("DEBUG :: On");

  SerialPort = serialport.SerialPort;

  sp = new SerialPort("/dev/tty" + argv.sp, {
    parser: serialport.parsers.readline("\n"),
    baudrate: 9600
  });

  connection = new cradle.Connection(CONFIG.dbHost, CONFIG.dbPort, {
    cache: false,
    raw: false
  });

  db = connection.database(CONFIG.dbName);

  i = 0;

  sensors = [];

  counter = 0;

  time_data = function(i) {
    var day, day_of_week, hour, millis, minutes, month, now, seconds, time_arr, time_str, timezone, today, year;
    now = new Date();
    today = now.toYMD("_");
    year = now.getFullYear();
    month = now.getMonth();
    day = now.getDate();
    hour = now.getHours();
    minutes = now.getMinutes();
    seconds = now.getSeconds();
    millis = now.getMilliseconds();
    day_of_week = now.getDay();
    timezone = now.getTimezoneOffset();
    time_str = today + "@" + hour + ":" + minutes + ":" + seconds + "." + millis + "@" + i;
    return time_arr = {
      time_arr: [year, month, day, hour, minutes, seconds, day_of_week, timezone],
      time_str: time_str
    };
  };

  sp.on("data", function(data) {
    var address, begin_data, enddata, handleSave, sensor, sensor_data, sensor_obj, splitted1, splitted2, splitted3, _i, _len;
    console.log("  " + data);
    begin_data = data.search("DATA");
    enddata = data.search("ENDDATA");
    splitted1 = data.split("A:");
    if (splitted1[1] !== void 0) {
      if (splitted1[1].search(",T: ") !== -1) {
        splitted2 = splitted1[1].split(",T: ");
      } else if (splitted1[1].search(",H: ") !== -1) {
        splitted2 = splitted1[1].split(",H: ");
      }
      splitted3 = splitted2[1].split("\r");
      sensor_data = parseFloat(splitted3[0]);
      console.log('sensor_data: ' + sensor_data);
      address = splitted2[0];
      sensor_obj = {
        data: sensor_data,
        address: address
      };
      sensors.push(sensor_obj);
    }
    if (enddata !== -1) {
      console.log('size' + sensors.length);
      for (_i = 0, _len = sensors.length; _i < _len; _i++) {
        sensor = sensors[_i];
        console.log(sensor.data);
      }
      handleSave = function(err, r) {
        return function(err, r) {
          if (argv.debug) console.log("DEBUG :: Saved to DB");
          if (err) throw new Error(err);
        };
      };
      if (db) {
        db.save(time_data(i).time_str, {
          time: new Date().getTime(),
          time_arr: time_data(i).time_arr,
          sensors: sensors
        }, handleSave());
      }
      if (argv.debug) {
        console.log("DEBUG :: Extracted :: Address: " + address + ", Temperature: " + sensor_data);
        console.log("DEBUG :: Saving to CouchDB ... ");
        console.log("DEBUG :: ENDDATA reached , incrementing ...");
        console.log("DEBUG :: sensors_length before : " + sensors.length);
        console.log("DEBUG :: DATA : counter : " + counter + "  Cleaning array...");
        sensors.splice(sensors.length - counter, counter);
        console.log("DEBUG :: sensors_length after: " + sensors.length);
      }
      i++;
      counter = 0;
    }
    if (data.search("A:") !== -1) return counter++;
  });

}).call(this);
