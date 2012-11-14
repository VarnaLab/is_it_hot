module.exports.output = output = (err, r) ->
  return (err, r) ->
      console.log "Saved to DB"
    if err 
      throw new Error(err)