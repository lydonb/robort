# Description:
#   Store a quote from a user, repeat it back to them at random times out of context.
#   Has a 1 in 200 (ish?) chance of delivering a quote whenever a person speaks.
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot outofcontext|ooc <user name>: <message> - add a quote for a user
#   hubot outofcontext|ooc rm <user name>: <message> - remove a quote for a user
#   hubot outofcontext|ooc list <user name>: - list messages for a user
#
# Author:
#   robotmay

appendQuote = (data, user, message) ->
  data[user.name] or= []
  data[user.name].push message

removeQuote = (data, user, message) ->
  index = data[user.name].indexOf(message)
  if (index != -1)
    data[user.name].splice(index, 1)
    return true
  else
    return false

listQuotes = (data, msg, user) ->
  quotes = data[user.name] or= []
  if quotes.length > 0
    msg.send "#user has said..."
    msg.send "#{id} - \"#{quote}\"" for quote, id in quotes
  else
    msg.send "#user hasn't said anything noteworthy."

findUser = (robot, msg, name, callback) ->
  users = robot.brain.usersForFuzzyName(name.trim())
  if users.length is 1
    user = users[0]
    callback(user)
  else if users.length > 1
    msg.send "Too many users like that"
  else
    msg.send "#{name}? Never heard of 'em"


  
module.exports = (robot) ->
  robot.brain.on 'loaded', =>
    robot.brain.data.oocQuotes ||= {}

  robot.respond /outofcontext|ooc (?!rm|list )(.*?): (.*)/i, (msg) ->
    findUser robot, msg, msg.match[1], (user) ->
      appendQuote(robot.brain.data.oocQuotes, user, msg.match[2])
      msg.send "Quote has been stored for future prosperity."

  robot.respond /outofcontext|ooc rm (.*?): (.*)/i, (msg) ->
    findUser robot, msg, msg.match[1], (user) ->
      removed = removeQuote(robot.brain.data.oocQuotes, user, msg.match[2])
      msg.send if removed then "Quote has been removed from historical records." else "Sorry Dave, we were unable to locate that message."

  robot.respond /outofcontext|ooc list (.*?):/i, (msg) ->
    msg.send "List hit"
    findUser robot, msg, msg.match[1], (user) ->
      listQuotes(robot.brain.data.oocQuotes, msg, user) 
  
  robot.hear /./i, (msg) ->
    return unless robot.brain.data.oocQuotes?
    if (quotes = robot.brain.data.oocQuotes[msg.message.user.name])
      randomQuote = quotes[Math.floor(Math.random() * quotes.length)]

      if Math.floor(Math.random() * 200) == 42
        msg.send "\"#{randomQuote}\" - #{msg.message.user.name}"

