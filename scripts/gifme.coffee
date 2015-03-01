# Description:
#   gifme command returns a preset gif according to a keyword
#
# Configuration:
#   None
#
# Commands:
#   robort gifme all
#   robort gifme add <keyword> <url>
#   robort gifme <keyword>
#   robort gifme <keyword> <alternateIndex>
#
# Author:
#   mjknowles

  gifMeUrl = "http://gifatme.azurewebsites.net/api/gifentries/"

  # Display the gifme api to interested boneheads - i mean users.
  gifMeApi = (cb) ->
    cb "Prefix all of these with 'robort' then your gifme command:" +
    "\nSave a gif for a keyword (url begin with http:// and end with .gif): gifme add highfive http://i.imgur.com/wJUHejF.gif" +
    "\nRetrieve a random gif for a keyword: gifme highfive" +
    "\nRetrieve a specific gif for a keyword (ordered in ascending order of upload): gifme highfive 2" +
    "\nRetrieve all of your gifs and keyords (not in general or random rooms): gifme all"

  # Display all the user's uploaded gifs
  gifMeAll = (robot, userName, room, cb) ->
    if room isnt "general" and room isnt "random"
      robot.http(gifMeUrl + userName)
        .header('Accept', 'application/json')
        .get() (err, res, body) ->
          # error checking code here
          if res.statusCode isnt 200
            cb "Request didn't come back HTTP 200 :("
            return
          cb JSON.parse(body).GifEntries

  # Add a gif to the user's collection
  gifMeAdd = (robot, userName, keyword, url, cb) ->
    data = JSON.stringify({
      Url: url
      UserName: userName
      Keyword: keyword
    })
    robot.http(gifMeUrl)
      .header("content-type","application/json")
      .post(data) (err, res, body) ->
        # error checking code here
        if err
          cb "Error: #{err}"
          return
        cb "Gif upload successful for #{keyword}"

  # Get a gif from the user's collection at the specified index
  # If user does not give index, the web app chooses a random one for the keyword
  gifMeGet = (robot, userName, keyword, index, cb) ->
    getUrl = gifMeUrl + "#{userName}/#{keyword}/"
    if !index
      getUrl += 0
    else
      getUrl += index
    robot.http(getUrl)
      .header('Accept', 'application/json')
      .get() (err, res, body) ->
        # error checking code here
        if res.statusCode isnt 200
          cb "Request didn't come back HTTP 200 :("
          return
        data = JSON.parse(body)
        cb data.GifEntry.Url

  module.exports = (robot) ->
    # Add a gif to the user's collection for the specified keyword
    robot.respond /gifme (add|all|api)?(( )?([^\s]+)( )?(\d+|http?:\/\/.*\.gif)?)?/i, (msg) ->
      firstWord = msg.match[1]
      userName = msg.message.user.name
      room = msg.message.room
      if firstWord is "api"
        gifMeApi (api) ->
          msg.send api
      else if firstWord is "all"
        gifMeAll robot, userName, room, (gifs) ->
          for gif in gifs
            msg.send "#{gif.Keyword} #{gif.AlternateIndex}: #{gif.Url}"
      else
        keyword = msg.match[4]
        if firstWord is "add"
          url = msg.match[6]
          gifMeAdd robot, userName, keyword, url, (response) ->
            msg.send response
        else
          # get a gif entry
          index = msg.match[6]
          gifMeGet robot, userName, keyword, index, (response) ->
            msg.send response
