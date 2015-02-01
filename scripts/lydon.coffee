# Description:
#   Lydon's responses
#
# Configuration:
#   None
#
# Commands:
#
# Author:
#   lydonb

module.exports = (robot) ->
  robot.hear /\:cpeck\:/i, (msg) ->
      msg.send "Shhhh... The boss is coming!"
  robot.hear /game of thrones/i, (msg) ->
    msg.send "No Spoilers!!"
  robot.hear /(your?|need|to) help/i, (msg) ->
    msg.send("Help will always be given at CTS to those who ask for it.")
  robot.hear /chris/i, (msg) ->
    msg.send(":cpeck:")
