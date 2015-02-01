# Description:
#   Returns information about FABLE sign-ups on fable.lydonbergin.com
#
# Configuration:
#   None
#
# Commands:
#   hubot next fable - display information about the next fable
#
# Author:
#   lydonb

module.exports = (robot) ->

  robot.respond /next fable/i, (msg) ->
    msg.http("http://fable.lydonbergin.com/fables.json")
      .get() (err, res, body) ->
        try
          json = JSON.parse(body)
          msg.send "The next FABLE is on " + json[0].date
          msg.http("http://fable.lydonbergin.com/sign_ups.json")
            .get() (err, res, body) ->
              signUps = JSON.parse(body)
              count = 0
              for signUp in signUps
                if signUp.fable_id is json[0].id
                  count++
                  msg.send "Topic " + count + ": " + signUp.topic.description
        catch error
          msg.send "Sorry, I couldn't figure it out. Lydon probably broke it."
