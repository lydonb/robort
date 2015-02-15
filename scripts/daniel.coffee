# Description:
#   everyonce tweaks
#
# Configuration:
#   HUBOT_DEEP_THOUGHT_URL='http://andymatthews.net/code/deepthoughts/get.cfm'
#
# Commands:
#   deep, room
# Author:
#   everyonce


module.exports = (robot) ->
    robot.respond /deep/i, (msg) ->
        msg.http(process.env.HUBOT_DEEP_THOUGHT_URL)
            .get() (error, response, body) ->
                data = JSON.parse(body)
                msg.send decodeURI(data.thought.replace(/&quot;/g,'"'))

    robot.respond /room/i, (msg) ->
        room = msg.message.room
        msg.send("The room is #{room}")

