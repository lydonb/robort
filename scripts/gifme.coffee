  # Description:
  #   gifme command returns a preset gif according to a keyword
  #
  # Configuration:
  #   None
  #
  # Commands:
  #   robort gifme all
  #   robort gifme add keyword url
  #   robort gifme keyword
  #   robort gifme keyword alternateIndex
  #
  # Author:
  #   mjknowles

  module.exports = (robot) ->

    # Display the gifme api to interested boneheads - i mean users.
    robot.respond /gifme api/i, (msg) ->
      msg.send "Prefix all of these with 'robort' then your gifme command:" +
      "\nSave a gif for a keyword (url begin with http: and end with .gif): gifme highfive http://i.imgur.com/wJUHejF.gif" +
      "\nRetrieve a random gif for a keyword: gifme highfive" +
      "\nRetrieve a specific gif for a keyword (ordered in ascending order of upload): gifme highfive 2" +
      "\nRetrieve all of your gifs and keyords (not in general or random rooms): gifme all"

    # Add a gif to the user's collection for the specified keyword
    robot.respond /gifme add (.*) (.*)/i, (msg) ->
      keyword = msg.match[1]
      url = msg.match[2]
      userName = msg.message.user.name
      data = JSON.stringify({
          Url: url
          UserName: userName
          Keyword: keyword
      })
      robot.http("http://gifatme.azurewebsites.net/api/gifentries")
        .post(data) (err, res, body) ->
          # error checking code here
          if err
            msg.send "Error: #{err}"
            return
          msg.send "Gif upload successful for #{keyword}"

    # Get a gif from the user's collection at the specified index
    # If user does not give index, the web app chooses a random one for the keyword
    ###

    The regular expression used to ignore the add or all commands
    does not work.

    robot.respond /gifme (^add|^all) ([0-9]*)/i, (msg) ->
      keyword = msg.match[1]
      index = msg.match[2]
      userName = msg.message.user.name
      robot.http("http://gifatme.azurewebsites.net/api/gifentries/#{userName}/#{keyword}/#{index}")
        .header('Accept', 'application/json')
        .get() (err, res, body) ->
          # error checking code here
          if res.statusCode isnt 200
            msg.send "Request didn't come back HTTP 200 :("
            msg.send "Error: #{err}"
            return
          data = JSON.parse(body)
          msg.send "#{data.GifEntry.Url}"
    ###

    # Display all the user's uploaded gifs
    robot.respond /gifme all/i, (msg) ->
      userName = msg.message.user.name
      room = msg.message.room
      if room isnt "general" and room isnt "random"
        robot.http("http://gifatme.azurewebsites.net/api/gifentries/#{userName}")
          .header('Accept', 'application/json')
          .get() (err, res, body) ->
            # error checking code here
            if res.statusCode isnt 200
              msg.send "Request didn't come back HTTP 200 :("
              msg.send "Error: #{err}"
              return
            data = JSON.parse(body)
            for gif in data.GifEntries
              msg.send "#{gif.Keyword} #{gif.Url} #{gif.AlternateIndex}"
