# Description:
#   emm386 will parrot back images or text stored
#
# Configuration:
#   None
#
# Commands:
#   hubot memry list
#   hubot memry keyword value1..n
#   hubot memry keyword
#
# Author:
#   everyonce
  crypto = require('crypto')

  # Display all the user's uploaded gifs
  buildKeywordHash = (userId, keyword) ->
    'emm386'+crypto.createHash('md5').update(userId.toString()).update(keyword).digest("hex")
  listAll = (robot, userId, cb) ->
    list= robot.brain.get(buildKeywordHash(userId,"LIST"))
    if list is null
      cb "I don't have anything memorized for you"
    else
      cb JSON.parse(list).join(", ")

  # Add a gif to the user's collection
  memAdd = (robot, userId, keyword, value, cb) ->
    robot.brain.set buildKeywordHash(userId,keyword), value.toString('base64')
    previousList = JSON.parse(robot.brain.get(buildKeywordHash(userId,"LIST")))
    if !previousList?
      previousList = []
    previousList.push keyword
    robot.brain.set buildKeywordHash(userId,"LIST"),JSON.stringify(previousList).toString('base64')
    cb "I'll remember #{keyword} forever"

  memGet = (robot, userId, keyword, cb) ->
    value = robot.brain.get(buildKeywordHash(userId,keyword))
    if value is null
      cb "I don't remember you telling me about "+keyword
    else
      cb value

  module.exports = (robot) ->
    robot.respond /(mem|memry|emm386) ([^\s]+)(\s+)?(.+)?/i, (msg) ->
      console.log "memry logging"
      keyword = msg.match[2]
      value = msg.match[4]
      user = msg.message.user
      room = msg.message.room
      if !value?
        if keyword is "list"
           console.log JSON.stringify(msg.match)
           listAll robot, user.id, (response) ->
             msg.send response
        else
           memGet robot, user.id, keyword, (response) ->
             msg.send response
      else
        memAdd robot, user.id, keyword, value, (response) ->
           msg.send response

