config = require 'config'
{Connection} = require("pachube-stream")

conn = new Connection(config.cosm.api_key)
conn.on "error", (error) ->
  console.log(error)

module.exports.put = put = (cosm_data) -> 
  req = conn.put "/feeds/" + config.cosm.api_key, cosm_data

  req.on "complete", (data) ->
    console.log "Cosm data sent"