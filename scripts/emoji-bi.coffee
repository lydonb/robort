module.exports = (robot) ->
  jackrabbit = require('jackrabbit')
  rabbit = jackrabbit(process.env.AMQP_CONN_STR)
  exchange = rabbit.fanout(process.env.AMQP_EXCHANGE)

  f = (msg) ->
    exchange.publish msg.message
  robot.hear /.*/, f
  robot.react f
