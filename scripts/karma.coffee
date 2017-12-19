# Description:
#   Track arbitrary karma
#
# Dependencies:
#   None
#
# Configuration:
#   KARMA_ALLOW_SELF
#
# Commands:
#   <thing>++ - give thing some karma
#   <thing>-- - take away some of thing's karma
#   hubot karma <thing> - check thing's karma (if <thing> is omitted, show the top 5)
#   hubot karma empty <thing> - empty a thing's karma
#   hubot karma best - show the top 5
#   hubot karma worst - show the bottom 5
#   hubot buy <number> karma - Purchase more karma allowance for the day
#
# Author:
#   stuartf

class Karma

  constructor: (@robot) ->
    @cache = {
      users: []
      , things: []
    }
    @allowances = {}
    @karma_allowance = 10

    @increment_responses = [
      "+1!", "killin' it!", "is en fuego!", "leveled up!"
    ]

    @robot.brain.on 'loaded', =>
      if @robot.brain.data.karma
        @cache = @robot.brain.data.karma
      if @robot.brain.data.karmaAllowances
        @allowances = @robot.brain.data.karmaAllowances
      @karma_allowance ?= process.env.KARMA_ALLOWANCE

  kill: (thing) ->
    thingObj = @robot.brain.userForName(thing)
    if thingObj?
      delete @cache.users[thingObj.id]
    else
      delete @cache.things[thing]
    @robot.brain.data.karma = @cache

  increment: (thing, actor) ->
    @allowances[actor.id] -= 1 if actor.id?
    thingObj = @robot.brain.userForName(thing)
    if thingObj?
      @cache.users[thingObj.id] ?= 0
      @cache.users[thingObj.id] += 1
    else
      @cache.things[thing] ?= 0
      @cache.things[thing] += 1
    @robot.brain.data.karma = @cache
    @robot.brain.data.karmaAllowances = @allowances

  decrement: (thing, actor) ->
    @allowances[actor.id] -= 1;
    @cache.users[actor.id] -= 2
    thingObj = @robot.brain.userForName(thing)
    if thingObj?
      @cache.users[thingObj.id] ?= 0
      @cache.users[thingObj.id] -= 1
    else
      @cache.things[thing] ?= 0
      @cache.things[thing] -= 1
    @robot.brain.data.karma = @cache
    @robot.brain.data.karmaAllowances = @allowances

  incrementResponse: ->
    @increment_responses[Math.floor(Math.random() * @increment_responses.length)]

  getAllowance: (user) ->
    if not @allowances[user.id]? then @allowances[user.id] = @karma_allowance
    return @allowances[user.id]

  clearAllowances: ->
    @allowances = {}
    @robot.brain.data.karmaAllowances = {}

  clearSingleAllowance: (user, karma) ->
    @cache.users[user.id] -= karma
    @allowances[user.id] += karma

  selfDeniedResponses: (name) ->
    @self_denied_responses = [
      "Hey everyone! #{name} is a narcissist!",
      "I might just allow that next time, but no.",
      "I can't do that #{name}.",
      "Shut it down, #{name}"
    ]

  shortOnKarmaResponses: (name) ->
    @short_on_karma_responses = [
      "#{name}: Get your own karma first, you slacker!",
      "To be the man, you've gotta beat the man, #{name}.",
      "You require more vespene gas, #{name}."
    ]

  decrementResponses: (name, thing, nKarma, sKarma) ->
    @decrement_responses = [
      "#{thing}(#{sKarma}) took a hit from #{name}(#{nKarma})! Ouch.",
      "#{thing}(#{sKarma}) got punked by #{name}(#{nKarma}).",
      "#{name}(#{nKarma}) took out a hit on #{thing}(#{sKarma}).",
      "#{name}(#{nKarma}) sabotaged #{thing}(#{sKarma}).",
      "#{thing}(#{sKarma}) lost a level because of #{name}(#{nKarma}).",
      "#{thing}(#{sKarma}) - ya burnt. #{name}(#{nKarma}) - ya burnter."
    ]

  get: (thing) ->
    thingObj = @robot.brain.userForName(thing)
    if thingObj?
        k = if @cache.users[thingObj.id]? then @cache.users[thingObj.id] else 0
    else
        k = if @cache.things[thing]? then @cache.things[thing] else 0
    return k

  sort: ->
    s = []
    for key, val of @cache.users
      user = @robot.brain.userForId(key)
      s.push({ name: user?.name, karma: val })
    for key, val of @cache.things
      s.push({ name: key, karma: val })
    s.sort (a, b) -> b.karma - a.karma

  top: (n = 5) ->
    sorted = @sort()
    sorted.slice(0, n)

  bottom: (n = 5) ->
    sorted = @sort()
    sorted.slice(-n).reverse()

  notify: (msg, subject, user, verb) ->
    msgPlace = switch msg.message.rawMessage.channel._modelName
      when "DM" then "in a direct message"
      when "Channel" then "in the channel \"#{msg.message.rawMessage.channel.name}\""
      when "Group" then "in the private channel \"#{msg.message.rawMessage.channel.name}\""
      else "by some means of sorcery"
    return "#{user.name} #{verb} #{subject} (Karma: #{this.get(subject)}) #{msgPlace}"

module.exports = (robot) ->
  karma = new Karma robot
  robot.karma = karma
  cronJob = require('cron').CronJob
  new cronJob('0 01 01 * * *', karma.clearAllowances, null, true, 'America/Chicago', karma)
  allow_self = process.env.KARMA_ALLOW_SELF or "true"
  notify_channel = process.env.KARMA_NOTIFY_CHANNEL or "karma"

  robot.hear /([\w\d\.\-\_\:]+)\+\+/, (msg) ->
    subject = msg.match[1].toLowerCase().replace /^@+/, ""
    user = msg.message.user
    if (karma.getAllowance(user) > 0) and (allow_self is true or user.name.toLowerCase() != subject)
      karma.increment subject, user
      msg.send "#{subject} #{karma.incrementResponse()} (Karma: #{karma.get(subject)})"
      robot.messageRoom(notify_channel, karma.notify(msg, subject, user, "incremented"));
    else if (karma.getAllowance(user) == 0)
      msg.send "#{user.name} isn't allowed to karma any more today!"
    else
      msg.send msg.random karma.selfDeniedResponses(user.name)

  robot.hear /([\w\d\.\-\_\:]+)--/, (msg) ->
    subject = msg.match[1].toLowerCase().replace /^@+/, ""
    user = msg.message.user
    if (karma.getAllowance(user) > 0) and (allow_self is true or user.name.toLowerCase() != subject) and (karma.get(user.name) >= 2)
      karma.decrement subject, user
      msg.send msg.random karma.decrementResponses(user.name, subject, karma.get(user.name), karma.get(subject))
      robot.messageRoom(notify_channel, karma.notify(msg, subject, user, "decremented"));
    else if (karma.getAllowance(user) == 0)
      msg.send "#{user.name} isn't allowed to karma any more today!"
    else if (karma.get(user.name) < 2)
      msg.send msg.random karma.shortOnKarmaResponses(user.name)
    else
      msg.send msg.random karma.selfDeniedResponses(user.name)

  robot.respond /karma empty ([\w\d\.\-\_\:]+)$/i, (msg) ->
    subject = msg.match[1].toLowerCase().replace /^@+/, ""
    if not robot.auth.hasRole(msg.message.user,'admin')
      msg.send "I can't let you do that..."
    else if allow_self is true or msg.message.user.name.toLowerCase() != subject
      karma.kill subject
      msg.send "#{subject} has had its karma scattered to the winds."
      robot.messageRoom(notify_channel, karma.notify(msg, subject, user, "killed"));
    else
      msg.send msg.random karma.selfDeniedResponses(msg.message.user.name)

  robot.respond /karma give allowance$/i, (msg) ->
    if not robot.auth.hasRole(msg.message.user,'admin')
      msg.send "I can't let you do that..."
    else 
      karma.allowances = {}
      msg.send "All right... everyone can play again..."

  robot.respond /karma show allowance$/i, (msg) ->
    for item, value of karma.allowances
      user = robot.brain.userForId(item)
      msg.send "#{user?.name}: #{value}"

  robot.respond /karma best$/i, (msg) ->
    if karma.top().length > 0
      verbiage = ["The Best"]
      for item, rank in karma.top()
        verbiage.push "#{rank + 1}. #{item.name}: #{item.karma}"
      msg.send verbiage.join("\n")

  robot.respond /karma worst$/i, (msg) ->
    if karma.bottom().length > 0
      verbiage = ["The Worst"]
      for item, rank in karma.bottom()
        verbiage.push "#{rank + 1}. #{item.name}: #{item.karma}"
      msg.send verbiage.join("\n")

  robot.respond /buy (\d+) karma$/i, (msg) ->
    user = msg.message.user
    request = parseInt msg.match[1]
    if request <= karma.get(user.name) and request > 0 and karma.getAllowance(user) == 0
      karma.clearSingleAllowance(user, request)
      msg.send "Congrats on your purchase, #{user.name}. Sucker."
    else
      msg.send "Sorry #{user.name}, your fingers are writing checks other parts of you can't cash."

  robot.respond /karma ([\w\d\.\-\_\:]+)$/i, (msg) ->
    match = msg.match[1].toLowerCase().replace /^@+/, ""
    if match != "best" && match != "worst"
      msg.send "\"#{match}\" has #{karma.get(match)} karma."
