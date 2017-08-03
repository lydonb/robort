module.exports = (robot) ->
  jackrabbit = require('jackrabbit')
  rabbit = jackrabbit(process.env.AMQP_CONN_STR)
  rabbit.default().queue({ name: 'slack' })
  p = (err) ->
    if (err)
      console.log err
  f = (msg) ->
    rabbit.default().publish msg.message, { key: 'slack' }, (err) -> p
  robot.hear /.*/, f
  robot.react f

