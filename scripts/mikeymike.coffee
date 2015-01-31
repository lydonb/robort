##################################
#
# NOBODY READ THIS OR ELSE YOU'LL
# RUIN THE FUN
#
#################################































































module.exports = (robot) ->
  robot.hear /s my name?/i, (msg) ->
    userName = msg.message.user.name
    if userName is "enichols"
      msg.reply "IT DOESN'T MATTER WHAT YOUR NAME IS!"
      msg.send "http://i.imgur.com/mPQP2xp.jpg"
    else
      nameResponses = ["Sir/Lady #{userName} of CTS",
                       "#{userName}, my master",
                       "#{userName} the great",
                       "#{userName} big balla shot calla"]

      msg.send msg.random nameResponses
