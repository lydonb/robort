# Description:
#   Track arbitrary achievements.
#
# Dependencies:
#   None
#
# Commands:
#   <thing> got <AchievemntName> - Gives <thing> an achivment called <AchievementName>
#   hubot achievements <thing> - Lists the Achievments awared to <Thing>.
#
# Author:
#   Andrew Riedel

class Achievements

  constructor: (@robot) ->
    @cache = {}

    @robot.brain.on 'loaded', =>
      if @robot.brain.data.achievements
        @cache = @robot.brain.data.achievements

  kill: (thing) ->
    delete @cache[thing]
    @robot.brain.data.achievements = @cache

  award: (thing, name, awarder) ->
    today = new Date()
    dd = today.getDate()
    mm = today.getMonth()+1
    yyyy = today.getFullYear()
    a = {
          name: name,
          awarder: awarder,
          date: mm+'/'+dd+'/'+yyyy
    }
    @cache[thing] ?= []
    @cache[thing].push(a)
    @robot.brain.data.achievements = @cache

  get: (thing) ->
    k = if @cache[thing] then @cache[thing] else 0
    return k

module.exports = (robot) ->
  achievements = new Achievements robot
  robot.achievements = achievements

  robot.hear /(\S+[^+:\s])( got )("\S+[^+:\s]")(\s|$)/, (msg) ->
    subject = msg.match[1].toLowerCase().replace /^\s+|\s+$/g, ""
    name = msg.match[3].toLowerCase()
    awarder = msg.message.user.name.toLowerCase()
    achievements.award(subject, name, awarder)
    msg.send "#{subject} got #{name}! (Awarded by #{awarder})"

  robot.respond /([a|A]chievements)( \S+[^+:\s])?/, (msg) ->
    if msg.match[2]?
      subject = msg.match[2].toLowerCase().replace /^\s+|\s+$/g, ""
      a = achievements.get(subject)
      if not a?
        msg.send "#{subject} doesn't have any achievements."
      if a.length == 1
        msg.send "#{subject} has #{a.length} achievement:"
      if a.length > 1
        msg.send "#{subject} has #{a.length} achievements:"
      verbiage = ""
      if a != 0
        for item in a
          verbiage += "#{item.name} awarded by #{item.awarder} on #{item.date}. \n"
        msg.send verbiage
