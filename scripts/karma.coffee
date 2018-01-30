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
    @khistory = []

    @increment_responses = [
      "FTW!", "killin' it!", "is en fuego!", "leveled up!", "ROCK-N-ROLL!"
    ]

    @robot.brain.on 'loaded', =>
      if @robot.brain.data.karma
        @cache = @robot.brain.data.karma
      if @robot.brain.data.karmaHistory
        @khistory = @robot.brain.data.karmaHistory
      @karma_allowance ?= process.env.KARMA_ALLOWANCE

  kill: (thing) ->
    thingObj = @robot.brain.userForName(thing)
    if thingObj?
      delete @cache.users[thingObj.id]
    else
      delete @cache.things[thing]
    @robot.brain.data.karma = @cache

  cleanKarmaHistory: (actor) ->
    if @khistory[actor.id]?
      DAY = 1000 * 60 * 60  * 24
      today = new Date()
      @khistory[actor.id] = (x for x in @khistory[actor.id] when (Math.round((today.getTime() - x) / DAY)) <= 7 )

  getKarmaHistory: (actor) ->
    if @khistory[actor.id]?
      DAY = 1000 * 60 * 60  * 24
      today = new Date()
      todayKarma = (x for x in @khistory[actor.id] when (Math.round((today.getTime() - x) / DAY)) == 0 )
      yesterdayKarma = (x for x in @khistory[actor.id] when (Math.round((today.getTime() - x) / DAY)) == 1 )
      return @khistory[actor.id].length + (yesterdayKarma.length*2) + (todayKarma.length*3)
    else 
      return 0

  getKarmaHistoryList: (actor) ->
    if @khistory[actor.id]?
      return @khistory[actor.id].join()
    else 
      return 'none'

  addKarmaHistory: (actor) ->
    if not @khistory[actor.id]?
      @khistory[actor.id] = []
    today = new Date  
    @khistory[actor.id].push today.getTime()
    @robot.brain.data.karmaHistory = @khistory
      
  getKarmaPower: (actor) ->
    maxKarmaPower = 3
    minKarmaPower = 0.01
    c1 = -0.5
    c2 = 3
    c3 = 0.008
    kv = @getKarmaHistory(actor)
    return Math.max(minKarmaPower,Math.min(maxKarmaPower,(c1 * Math.log(kv)) + c2 - (kv*c3)))
    
  increment: (thing, actor) ->
    @cleanKarmaHistory(actor)
    kPower = @getKarmaPower(actor)
    @addKarmaHistory(actor)
    thingObj = @robot.brain.userForName(thing)
    if thingObj?
      @cache.users[thingObj.id] ?= 0
      @cache.users[thingObj.id] += kPower
    else
      @cache.things[thing] ?= 0
      @cache.things[thing] += kPower
    @robot.brain.data.karma = @cache
    return kPower

  decrement: (thing, actor) ->
    @cache.users[actor.id] -= 2
    thingObj = @robot.brain.userForName(thing)
    if thingObj?
      @cache.users[thingObj.id] ?= 0
      @cache.users[thingObj.id] -= 1
    else
      @cache.things[thing] ?= 0
      @cache.things[thing] -= 1
    @robot.brain.data.karma = @cache

  incrementResponse: ->
    @increment_responses[Math.floor(Math.random() * @increment_responses.length)]

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

module.exports = (robot) ->
  karma = new Karma robot
  robot.karma = karma
  allow_self = process.env.KARMA_ALLOW_SELF or "true"

  robot.hear /([\w\d\.\-\_\:]+)\+\+/, (msg) ->
    subject = msg.match[1].toLowerCase().replace /^@+/, ""
    user = msg.message.user
    if (allow_self is true or user.name.toLowerCase() != subject)
      powerOutput = karma.increment subject, user
      msg.send "#{subject} +#{Math.round(powerOutput*100)/100} #{karma.incrementResponse()} (Karma: #{Math.round(karma.get(subject)*100)/100})"
    else
      msg.send msg.random karma.selfDeniedResponses(user.name)

  robot.hear /([\w\d\.\-\_\:]+)--/, (msg) ->
    subject = msg.match[1].toLowerCase().replace /^@+/, ""
    user = msg.message.user
    if (allow_self is true or user.name.toLowerCase() != subject) and (karma.get(user.name) >= 2)
      karma.decrement subject, user
      msg.send msg.random karma.decrementResponses(user.name, subject, karma.get(user.name), karma.get(subject))
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
    else
      msg.send msg.random karma.selfDeniedResponses(msg.message.user.name)

  robot.respond /karma history$/i, (msg) ->
    msg.send "Recent karma: #{karma.getKarmaHistoryList(msg.message.user)}"

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

  robot.respond /karma ([\w\d\.\-\_\:]+)$/i, (msg) ->
    match = msg.match[1].toLowerCase().replace /^@+/, ""
    if match != "best" && match != "worst"
      msg.send "\"#{match}\" has #{karma.get(match)} karma."
