##################################
#
# NOBODY READ THIS OR ELSE YOU'LL
# RUIN THE FUN
#
#################################































































module.exports = (robot) ->
  robot.hear /s (.*) name?/i, (msg) ->
    nounInQuestion = msg.match[1]
    if nounInQuestion is "my"
      msg.reply "IT DOESN'T MATTER WHAT YOUR NAME IS!"
    else
      msg.reply "IT DOESN'T MATTER WHAT #{nounInQuestion} IS!""
