# Description:
#   Track arbitrary achievements purchesed with karma.
#
# Dependencies:
#  karma.coffee
#
# Commands:
#   <thing> get <AchievemntName> <KarmaValue> - give <thing> an achivment called <AchievementName>
#               worth <KarmaValue>. Decrements awarders karma by <KarmaValue>. If <KarmaValue> is
#               ommitted then it will default to the min value (configurable).
#   hubot achievements <thing> - Lists the Achievments awared to <Thing> by their karma value.
#   hubot achievements best - show the top 5 Achievemtns and their owner based on karma value.
#
# Author:
#   Andrew Riedel

class Achievments

  constructor: (@robot) ->
    @cache = {}
    @min_cost = 10

    @robot.brain.on 'loaded', =>
      if @robot.brain.data.achievments
        @cache = @robot.brain.data.achievments

  kill: (thing) ->
    delete @cache[thing]
    @robot.brain.data.achievments = @cache

  award: (thing, name, value = @karma_min_cost, awarder) ->
    @cache[thing] ?= []
    @cache[thing].push {
                        name: name,
                        value: value,
                        awarder: awarder
                       }
    @robot.brain.data.achievments = @cache

  get: (thing) ->
    k = if @cache[thing] then @cache[thing] else 0
    return k

  sort: ->
    s = []
    for key, val of @cache
      for key2, val2 of val
        s.push({ name: key, achivement: val })
    s.sort (a, b) -> b.achivement.value - a.achievement.value

  top: (n = 5) ->
    sorted = @sort()
    sorted.slice(0, n)

module.exports = (robot) ->
  achievments = new Achivements robot
  robot.achievments = achievments

  robot.hear /(\S+[^+:\s])( get )("\S+[^+:\s]")(\s?[0-9]+)?(\s|$)/, (msg) ->
    subject = msg.match[1].toLowerCase()
    name = msg.match[3].toLowerCase()
    value = msg.match[4] ? achievments.min_cost
    awarder = msg.message.user.name.toLowerCase()
    achievments.award(subject, name, value, awarder)
    msg.send "#{subject} got #{name} worth #{value}! (Awarded by #{awarder})"
    #if (karma.getAllowance(name) > 0) and (allow_self is true or name != subject)
    #  karma.increment subject, name
    #  msg.send "#{subject} #{karma.incrementResponse()} (Karma: #{karma.get(subject)})"
    #else if (karma.getAllowance(name) == 0)
    #  msg.send "#{name} isn't allowed to karma any more today!"
    #else
    #  msg.send msg.random karma.selfDeniedResponses(msg.message.user.name)

  robot.respond /([a|A]chievments)( \S+[^+:\s])?, (msg) ->
    if msg.match[2]?
      subject = msg.match[2].toLowerCase()
      achives = achievements.get(subject)
      if achives != 0
        for item, rank in achives
          verbiage.push "#{item.name} #{item.value} #{item.awarder}"
        msg.send verbiage.join("\n")
