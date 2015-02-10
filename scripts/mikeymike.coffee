##################################
#
# NOBODY READ THIS OR ELSE YOU'LL
# RUIN THE FUN
#
#################################































































module.exports = (robot) ->
  # Call webAPI to return a specific gif
  robot.respond /gifme (.*)/i, (msg) ->
    gifKeyword = msg.match[1]
    robot.http("http://gifatme.azurewebsites.net/api/gifentries/#{gifKeyword}")
    .header('Accept', 'application/json')
    .get() (err, res, body) ->
      # error checking code here
      if res.statusCode isnt 200
        msg.send "Request didn't come back HTTP 200 :("
        return

      data = JSON.parse(body)
      msg.send "#{data.Url}"

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
