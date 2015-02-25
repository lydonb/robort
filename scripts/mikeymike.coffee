# Description:
#   Adding a bosheet comment so people will get off my case
#
# Configuration:
#   None
#
# Commands:
#   *s my name - robort will give you a pre-programmed name
#
# Author:
#   mjknowles































































module.exports = (robot) ->
  # THE ROCK SAYS KNOW YOUR ROLE
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
