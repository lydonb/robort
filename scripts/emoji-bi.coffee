module.exports = (robot) ->
  azure = require('azure')
  sb = azure.createServiceBusService(process.env.AZURE_SB_CONN_STR)
  f = (msg) ->
    sb.sendQueueMessage 'fable', JSON.stringify(msg.message), (err) ->
      if (err)
        console.log err
  robot.hear /.*/, f
  robot.react f

