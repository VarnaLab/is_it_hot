module.exports.time_data = time_data = (i) ->
  now = new Date()
  today = now.toYMD("_")
  year = now.getFullYear()
  month = now.getMonth()
  day = now.getDate()
  hour = now.getHours()
  minutes = now.getMinutes()
  seconds = now.getSeconds()
  millis = now.getMilliseconds()
  day_of_week = now.getDay()
  timezone = now.getTimezoneOffset()
  time_str = today + "@" + hour + ":" + minutes + ":" + seconds + "." + millis + "@" + i

  time_arr = { time_arr: [year, month, day, hour, minutes, seconds, day_of_week , timezone], time_str: time_str }
  