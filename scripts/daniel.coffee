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


Util = require "util"
request = require "request"
qs = require "querystring"
conspire = require 'conspire'

module.exports = (robot) ->
    robot.respond /deep/i, (msg) ->
        msg.http(process.env.HUBOT_DEEP_THOUGHT_URL)
            .get() (error, response, body) ->
                data = JSON.parse(body)
                msg.send decodeURI(data.thought.replace(/&quot;/g,'"'))

    robot.respond /room/i, (msg) ->
        room = msg.message.room
        msg.send("The room is #{room}")

    #robot.hear /tired|too hard|to hard|upset|bored/i, (msg) ->
    #    msg.send "Panzy"

    robot.hear /^\""".+\"""$/i, (msg) ->
        api=process.env.HUBOT_MUSIXMATCHAPI
        mylyrics=msg.message.text.replace(/&quot;/g,'')
        msg.http("http://api.musixmatch.com/ws/1.1/track.search?q_lyrics=#{mylyrics}&apikey=#{api}&s_track_rating=DESC&page_size=1")
            .get() (error, response, body) ->
                track = JSON.parse(body).message.body.track_list[0].track;
                if (track?)
                   responses = ['Nice choice.', 'You have interesting tastes!', 'I&apos;ll remember this next time you recommend a song...', 'Wow... just.  wow.', 'Great selection!']
                   thisresponse = msg.random responses
                   msg.send "Were you quoting #{track.track_name} by #{track.artist_name}? #{thisresponse}"
                   if track.track_spotify_id?.length
                      msg.send "http://open.spotify.com/track/#{track.track_spotify_id}"
    robot.hear /^(#)?.*/i, (msg) ->
        msg.http(process.env.HUBOT_NLP_URI).headers('Content-Type': 'application/json').post(JSON.stringify(msg.message)) 

    robot.respond /conspiracy me\b/i, (msg) ->
       msg.send conspire()

##Community
