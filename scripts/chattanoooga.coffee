# Description:
#   Listens to change Chattanooga to Chattanoooga due to Geekathlon 2016 T-Shirt 
#
# Configuration:
#   None
#
# Commands:
#   None
#
# Author:
#   Rob Retzlaff

module.exports = (robot) ->

  robot.hear /chattanooga/i, (msg) ->
    robot.brain.data.chattanooga++
    msg.send "I think you mean Chattanoooga, #{msg.message.user.name}. Chattanoooga has been incorrectly spelled #{robot.brain.data.chattanooga} times."

  robot.hear /chattan(o){3,}ga/i, (msg) ->
    msg.send "Thanks for spelling #{msg.match[0]} properly, #{msg.message.user.name}."
