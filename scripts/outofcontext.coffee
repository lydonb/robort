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
#   hubot ooc add <user name> <message> - add a quote for a user
#   hubot ooc rm <user name> <message> - remove a quote for a user
#   hubot ooc list <user name> - list quotes for a user
#
# Author:
#   robotmay

OOC_CHANCE = process.env.OOC_CHANCE or= 200

appendQuote = (data, user, message) ->
  data[user.id] or= []
  data[user.id].push message

removeQuote = (data, user, message) ->
  index = data[user.id].indexOf(message)
  if (index != -1)
    data[user.id].splice(index, 1)
    return true
  else
    return false

listQuotes = (data, msg, user) ->
  quotes = data[user.id] or= []
  quoteMsg = ""
  if quotes.length > 0
    quoteMsg += "#{user.name} has said...\n"
    quoteMsg += "\"#{quote}\"\n" for quote in quotes
    msg.send "#{quoteMsg}"
  else
    msg.send "#{user.name} hasn't contributed anything of consequence."

findUser = (robot, msg, name, callback) ->
  user = robot.brain.userForName(name.trim())
  if user?
    callback(user)
  else
    msg.send "#{name}? Never heard of 'em"
  
module.exports = (robot) ->
  robot.brain.on 'loaded', =>
    robot.brain.data.oocQuotes ||= {}

  robot.respond /ooc add ([^\s]+) (.*)/i, (msg) ->
    findUser robot, msg, msg.match[1], (user) ->
      appendQuote(robot.brain.data.oocQuotes, user, msg.match[2])
      msg.send "Quote has been stored for future prosperity."

  robot.respond /ooc rm ([^\s]+) (.*)/i, (msg) ->
    findUser robot, msg, msg.match[1], (user) ->
      removed = removeQuote(robot.brain.data.oocQuotes, user, msg.match[2])
      msg.send if removed then "Quote has been removed from historical records." else "Sorry Dave, we were unable to locate that message."
  
  robot.respond /ooc list ([^\s]+)/i, (msg) ->
    findUser robot, msg, msg.match[1], (user) ->
      listQuotes(robot.brain.data.oocQuotes, msg, user)

  robot.hear /./i, (msg) ->
    quotes = robot.brain.data.oocQuotes[msg.message.user.id] or= []
    return unless quotes.length > 0    
    randomQuote = quotes[Math.floor(Math.random() * quotes.length)]
    if Math.random() * OOC_CHANCE < 1
      msg.send "\"#{randomQuote}\" - #{msg.message.user.name}"

