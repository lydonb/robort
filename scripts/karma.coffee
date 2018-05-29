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

allow_self = process.env.KARMA_ALLOW_SELF or "false"
daysWatched = process.env.KARMA_DAYS_WATCHED or 14
max_power = process.env.KARMA_MAX_POWER or 3
min_power = process.env.KARMA_MIN_POWER or 0.01
milliseconds = 1000 * 60 * 60 * 24

class Karma

  constructor: (@robot) ->
    @karma = {
      users: []
      , things: []
    }
    @khistory = []

    @robot.brain.on 'loaded', =>
      if @robot.brain.data.karma
        @karma = @robot.brain.data.karma
      if @robot.brain.data.karmaHistory
        @khistory = @robot.brain.data.karmaHistory

  clearKarma: (thing) ->
    thingObj = @robot.brain.userForId(thing)
    if thingObj.slack?
      delete @karma.users[thingObj.id]
    else
      delete @karma.things[thing]
    @robot.brain.data.karma = @karma

  clearHistory: (thing) ->
    thingObj = @robot.brain.userForId(thing)
    delete @khistory[thingObj.id] if thingObj.slack?
    @robot.brain.data.karmaHistory = @khistory

  cleanKarmaHistory: (actorId) ->
    if @khistory[actorId]?
      today = new Date()
      @khistory[actorId] = (x for x in @khistory[actorId] when (Math.round((today.getTime() - x) / milliseconds)) <= daysWatched)

  getKarmaHistoryValue: (actorId) ->
    if @khistory[actorId]?
      today = new Date()
      todayKarma = (x for x in @khistory[actorId] when (Math.round((today.getTime() - x) / milliseconds)) == 0 )
      yesterdayKarma = (x for x in @khistory[actorId] when (Math.round((today.getTime() - x) / milliseconds)) == 1 )
      @khistory[actorId].length + (yesterdayKarma.length*2) + (todayKarma.length*3)
    else 
      0

  getKarmaHistoryList: (actorId) ->
    @khistory[actorId] ? []

  addKarmaHistory: (actorId) ->
    @khistory[actorId] ?= []
    today = new Date  
    @khistory[actorId].push today.getTime()
    @robot.brain.data.karmaHistory = @khistory
      
  getKarmaPower: (actorId) ->
    c1 = -0.5
    c2 = 3
    c3 = 0.008
    kv = @getKarmaHistoryValue(actorId)
    return Math.round(Math.max(min_power,Math.min(max_power,(c1 * Math.log(kv)) + c2 - (kv*c3))) * 100) / 100
    
  increment: (thing, actor, source) ->
    actorName = @getNameFromId(actor.id)
    user = @robot.brain.data.users[thing] or []
    @robot.logger.info thing
    @robot.logger.info source
    return "I'm going to assume you didn't mean a person named #{thing}." if thing.toLowerCase() in ["c", "notepad"]
    return @getResponse(@selfDeniedResponses("@#{actorName}")) if allow_self.toLowerCase() == 'false' and actor.id == user.id    
 
    if thing.toLowerCase() == "swearjar" and source.toLowerCase() == "profanity"
      @robot.logger.info "Got inside"
      @karma.things[thing] ?= 0
      @karma.things[thing] = @computeFloats(@karma.things[thing], 1, "+")
      @robot.logger.info @karma.things[thing]
      @robot.brain.data.karma = @karma
      return

    return "Looks like @#{thing} is a user. Try adding a \"@\" before it to properly modify karma." if @isFoundIn(thing, @displayNames())
    @cleanKarmaHistory(actor.id)
    actorKarmas = @getKarmaHistoryList(actor.id).sort().reverse()
    lastKarma = actorKarmas.slice(0, 1).pop() ? 0
    return "Try again later (after #{@timestampToDateTime(lastKarma + (milliseconds * daysWatched))}) @#{@actorName} - You've been a little overzealous in giving away karma lately." if actorKarmas.length >= daysWatched * 30
    kPower = @getKarmaPower(actor.id)
    if user.slack?
      @karma.users[thing] ?= 0
      @karma.users[thing] = @computeFloats(@karma.users[thing], kPower, "+")
      thingName = "@#{@getNameFromId(thing)}"
    else
      @karma.things[thing] ?= 0
      @karma.things[thing] = @computeFloats(@karma.things[thing], kPower, "+")
      thingName = thing
    @addKarmaHistory(actor.id)
    @robot.brain.data.karma = @karma
    "#{thingName} +#{kPower} #{@getResponse(@incrementResponses())} (Karma: #{@get(thing)})"

  decrement: (thing, actor) ->
    return "Looks like @#{thing} is a user. Try adding a \"@\" before it to properly modify karma." if @isFoundIn(thing, @displayNames())
    actorKarma = @get(actor.id)
    actorName = @getNameFromId(actor.id)
    user = @robot.brain.data.users[thing] or []
    return @getResponse(@shortOnKarmaResponses("@#{actorName}")) if actorKarma < 2
    return @getResponse(@selfDeniedResponses("@#{actorName}")) if allow_self is false and actor.id == user.id    
    @karma.users[actor.id] = @computeFloats(@karma.users[actor.id], 2, "-")
    if user.slack?
      @karma.users[thing] ?= 0
      @karma.users[thing] = @computeFloats(@karma.users[thing], 1, "-")
      thingName = "@#{@getNameFromId(thing)}"
    else
      @karma.things[thing] ?= 0
      @karma.things[thing] = @computeFloats(@karma.things[thing], 1, "-")
      thingName = thing
    @robot.brain.data.karma = @karma
    @getResponse(@decrementResponses(actorName, thingName, @get(actor.id), @get(thing)))

  getResponse: (responses) ->
    return responses[Math.floor(Math.random() * responses.length)]

  incrementResponses: -> 
    @increment_responses = [
      "FTW!"
      , "killin' it!"
      , "is en fuego!"
      , "leveled up!"
      , "ROCK-N-ROLL!"
      , "gained a point!"
    ]

  selfDeniedResponses: (name) ->
    @self_denied_responses = [
      "Hey everyone! #{name} is a narcissist!"
      , "I might just allow that next time, but no."
      , "#{name}, I can't do that."
      , "That's a funny one, #{name}. But seriously, stop trying."
      , "Why you tryin' to cheat the system, #{name}?"
      , "No."
      , "Definitely not."
      , "Not in a million years."
      , "*sigh* #{name} again? You should have learned the rules by now!"
    ]

  shortOnKarmaResponses: (name) ->
    @short_on_karma_responses = [
      "#{name}: Get your own karma first, you slacker!"
      , "#{name} - To be the man, you've gotta beat the man."
      , "You require more vespene gas."
      , "#{name}'s mouth is writing checks their karma can't cash."
      , "Please acquire more resources to complete this action."
      , "You ain't got the cheese for a request like that."
      , "#{name}! If I've told you once, I've told you a thousand times..."
      , "You're trying to cheat, #{name}? Not in my house."
    ]

  decrementResponses: (name, thing, nKarma, tKarma) ->
    @decrement_responses = [
      "#{thing}(#{tKarma}) took a hit from @#{name}(#{nKarma})! Ouch."
      , "#{thing}(#{tKarma}) got punked by @#{name}(#{nKarma})."
      , "@#{name}(#{nKarma}) took out a hit on #{thing}(#{tKarma})."
      , "@#{name}(#{nKarma}) sabotaged #{thing}(#{tKarma})."
      , "#{thing}(#{tKarma}) lost a level because of @#{name}(#{nKarma})."
      , "#{thing}(#{tKarma}) - ya burnt. @#{name}(#{nKarma}) - ya burnter."
    ]

  get: (thing) ->
    user = @robot.brain.data.users[thing]
    if user?.slack?
      k = if @karma.users[thing]? then @karma.users[thing] else 0
    else
      k = if @karma.things[thing]? then @karma.things[thing] else 0
    k

  sort: ->
    s = []
    s.push ({ name: "@#{@getNameFromId(key)}", karma: val }) for key, val of @karma.users
    s.push ({ name: key, karma: val }) for key, val of @karma.things
    s.sort (a, b) -> b.karma - a.karma

  top: (n = 5) ->
    @sort().slice(0, n)

  bottom: (n = 5) ->
    @sort().slice(-n).reverse()

  displayNames: ->
    userNames = []
    userNames.push (if user?.slack?.profile?.display_name != "" then user?.slack?.profile?.display_name else user?.slack?.profile?.real_name) for key, user of @robot.brain.users() when user?.slack?.deleted is false
    userNames

  getNameFromId: (userId) ->
    (if user?.slack?.profile?.display_name != "" then user?.slack?.profile?.display_name else user?.slack?.profile?.real_name) for key, user of @robot.brain.users() when user?.slack?.deleted is false and user?.id == userId

  isFoundIn: (search, array) ->
    array.indexOf(search) isnt -1

  timestampToDateTime: (timestamp) ->
    date = new Date(timestamp)
    date.toLocaleDateString('en-US', {timeZone: 'America/Chicago'}) + ' @ ' + date.toLocaleTimeString('en-US', {timeZone: 'America/Chicago'})

  computeFloats: (input1, input2, operator) ->
    switch operator
      when "+" then Math.round(input1 * 100 + input2 * 100) / 100
      when "-" then Math.round(input1 * 100 - input2 * 100) / 100
      when "*" then Math.round(input1 * 100 * input2 * 100) / 100
      when "/" then Math.round(input1 * 100 / input2 * 100) / 100

module.exports = (robot) ->
  karma = new Karma robot
  robot.karma = karma
  subjectString = "([\\w\\d\\[\\]\\-\\_\\{\\}\\,\\.\\/\\;\\(\\)\\'\\:]+?)"

  robot.hear new RegExp("#{subjectString}\\s*?(\\+\\+|\\-\\-)", "g"), (msg) ->
    if (msg.message.user.id.trim().substr(0,1).toLowerCase() == "u")
      responses = []
      increments = msg.message.rawText.replace(/[\<\>]/g, "").match(/[^\s\@]+\s*?\+\+(?!\:)/g) ? []
      responses.push (karma.increment subject.replace(/([^\s\@]+)\s*?(\+\+)/g, '$1'), msg.message.user, 'user') for subject, i in increments when i < 10 
      decrements = msg.message.rawText.replace(/[\<\>]/g, "").match(/[^\s\@]+\s*?\-\-(?!\:)/g) ? []
      responses.push (karma.decrement subject.replace(/([^\s\@]+)\s*?(\-\-)/g, '$1'), msg.message.user) for subject, i in decrements when i < 10
      msg.send responses.join("\n")

  robot.respond new RegExp("karma empty \@?#{subjectString}$", "i"), (msg) ->
    match = msg.message.rawText.match(/\s([^\s]+?)$/)
    subject = match[1].replace(/[\<\>\@]/g, "")
    if match[1] == subject and karma.isFoundIn(subject, karma.displayNames())
      msg.send "Looks like @#{subject} is a user. Try adding a \"@\" before it to properly modify karma."
    else if not robot.auth.hasRole(msg.message.user,'admin')
      msg.send "I can't let you do that..."
    else
      karma.kill subject
      msg.send "{if match[1] == subject then subject else '@' + karma.getName(subject)} has had its karma scattered to the winds."
  
  #This command should respond with a user-readable format of previous karmas
  #robot.respond /karma history$/i, (msg) ->
  #  msg.send "Recent karma: #{karma.getKarmaHistoryList(msg.message.user)}"

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

  robot.respond new RegExp("karma \@?#{subjectString}$", "i"), (msg) ->
    match = msg.message.rawText.match(/\s([^\s]+?)$/)
    subject = match[1].replace(/[\<\>\@]/g, "")
    if match[1] == subject and karma.isFoundIn(subject, karma.displayNames())
      msg.send "Looks like @#{subject} is a user. Try adding a \"@\" before it to properly allocate the karma."
    else if subject not in ["best", "worst", "history"]
      msg.send "\"#{if match[1] == subject then subject else '@' + karma.getNameFromId(subject)}\" has #{karma.get(subject)} karma."
