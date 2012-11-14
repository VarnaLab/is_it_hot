module.exports.parse = parse = (data) ->
  # example_format : <sn:2807631E0300000D,data:20.94,type:temperature>
  sensors = []

  sliced = data.slice(1,-2)
  splitted = sliced.split ","

  sensor_sn_arr = splitted[0].split "sn:"
  sensor_data_arr = splitted[1].split "data:"
  sensor_data_type_arr = splitted[2].split "type:"

  sensor_sn = sensor_sn_arr[1]
  sensor_data = parseFloat sensor_data_arr[1]
  sensor_data_type = sensor_data_type_arr[1]

  sensor_obj = {data: sensor_data, sn: sensor_sn}
  sensors.push sensor_obj