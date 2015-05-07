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
#
# Author:
#   stuartf

class Karma

  constructor: (@robot) ->
    @cache = {}
    @allowances = {}
    @karma_allowance = 10

    @increment_responses = [
      "+1!", "killin it!", "is en fuego!", "leveled up!"
    ]

    @robot.brain.on 'loaded', =>
      if @robot.brain.data.karma
        @cache = @robot.brain.data.karma
      if @robot.brain.data.karmaAllowances
        @allowances = @robot.brain.data.karmaAllowances
      @karma_allowance ?= process.env.KARMA_ALLOWANCE

  kill: (thing) ->
    delete @cache[thing]
    @robot.brain.data.karma = @cache

  increment: (thing, name) ->
    @allowances[name] -= 1;
    @cache[thing] ?= 0
    @cache[thing] += 1
    @robot.brain.data.karma = @cache
    @robot.brain.data.karmaAllowances = @allowances

  decrement: (thing, name) ->
    @allowances[name] -= 1;
    @cache[name] -= 2
    @cache[thing] ?= 0
    @cache[thing] -= 1
    @robot.brain.data.karma = @cache
    @robot.brain.data.karmaAllowances = @allowances

  incrementResponse: ->
     @increment_responses[Math.floor(Math.random() * @increment_responses.length)]

  getAllowance: (name) ->
    if not (@allowances[name]?) then  @allowances[name] = @karma_allowance
    return @allowances[name]

  clearAllowances: ->
    @allowances = {}
    @robot.brain.data.karmaAllowances = {}

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
      "You need more vespene gas, #{name}."
    ]

  decrementResponses: (name, subject, nKarma, sKarma) ->
    @decrement_responses = [
      "#{subject}(#{sKarma}) took a hit from #{name}(#{nKarma})! Ouch.",
      "#{subject}(#{sKarma}) got punked by #{name}(#{nKarma}).",
      "#{name}(#{nKarma}) took out a hit on #{subject}(#{sKarma}).",
      "#{name}(#{nKarma}) sabotaged #{subject}(#{sKarma})",
      "#{subject}(#{sKarma}) lost a level because of #{name}(#{nKarma}).",
      "#{subject}(#{sKarma}) - ya burnt. #{name}(#{nKarma}) - ya burnter"
    ]

  get: (thing) ->
    k = if @cache[thing] then @cache[thing] else 0
    return k

  sort: ->
    s = []
    for key, val of @cache
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
  cronJob = require('cron').CronJob
  new cronJob('0 01 01 * * *', karma.clearAllowances, null, true, 'America/Chicago', karma)
  allow_self = process.env.KARMA_ALLOW_SELF or "true"

  robot.hear /(\S+[^+:\s])[: ]*\+\+(\s|$)/, (msg) ->
    subject = msg.match[1].toLowerCase()
    name = msg.message.user.name.toLowerCase()
    if (karma.getAllowance(name) > 0) and (allow_self is true or name != subject)
      karma.increment subject, name
      msg.send "#{subject} #{karma.incrementResponse()} (Karma: #{karma.get(subject)})"
    else if (karma.getAllowance(name) == 0)
      msg.send "#{name} isn't allowed to karma any more today!"
    else
      msg.send msg.random karma.selfDeniedResponses(msg.message.user.name)

  robot.hear /(\S+[^-:\s])[: ]*--(\s|$)/, (msg) ->
    subject = msg.match[1].toLowerCase()
    name = msg.message.user.name.toLowerCase()
    if (karma.getAllowance(name) > 0) and (allow_self is true or name != subject) and (karma.get(name) >= 2)
      karma.decrement subject, name
      msg.send msg.random karma.decrementResponses(msg.message.user.name, subject, karma.get(name), karma.get(subject))
    else if (karma.getAllowance(name) == 0)
      msg.send "#{name} isn't allowed to karma any more today!"
    else if (karma.get(name) < 2)
      msg.send msg.random karma.shortOnKarmaResponses(msg.message.user.name)
    else
      msg.send msg.random karma.selfDeniedResponses(msg.message.user.name)

  robot.respond /karma empty ?(\S+[^-\s])$/i, (msg) ->
    subject = msg.match[1].toLowerCase()
    if not robot.auth.hasRole(msg.envelope.user,'admin')
      msg.send "I can't let you do that..."
    else if allow_self is true or msg.message.user.name.toLowerCase() != subject
      karma.kill subject
      msg.send "#{subject} has had its karma scattered to the winds."
    else
      msg.send msg.random karma.selfDeniedResponses(msg.message.user.name)

  robot.respond /karma give allowance$/i, (msg) ->
    karma.allowances = {}
    msg.send "All right... everyone can play again..."

  robot.respond /karma show allowance$/i, (msg) ->
    for item, value of karma.allowances
      msg.send "#{item}: #{value}"

  robot.respond /karma( best)?$/i, (msg) ->
    verbiage = ["The Best"]
    for item, rank in karma.top()
      verbiage.push "#{rank + 1}. #{item.name}: #{item.karma}"
    msg.send verbiage.join("\n")

  robot.respond /karma worst$/i, (msg) ->
    verbiage = ["The Worst"]
    for item, rank in karma.bottom()
      verbiage.push "#{rank + 1}. #{item.name}: #{item.karma}"
    msg.send verbiage.join("\n")

  robot.respond /karma (\S+[^-\s])$/i, (msg) ->
    match = msg.match[1].toLowerCase()
    if match != "best" && match != "worst"
      msg.send "\"#{match}\" has #{karma.get(match)} karma."
