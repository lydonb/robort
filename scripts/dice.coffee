# Description:
#   Allows Hubot to roll dice
#
# Dependencies:
#   None
#
# Configuration:
#   None
#
# Commands:
#   hubot roll (die|one)<(+-)#> - Roll one six-sided dice <optionally add or subtract # from die>
#   hubot roll dice  - Roll two six-sided dice <optionally add or subtract # from each die>
#   hubot roll <x>d<y><(+-)#> - roll x dice, each of which has y sides <optionally add or subtract # from each die>
#
# Author:
#   ab9

module.exports = (robot) ->
  robot.respond /roll (die|one)(\s?\[-+]\s?(\d+))?/i, (msg) ->
    variant = msg.match[2] or= "+"
    offset = parseInt msg.match[3] or= 0 * variant.indexOf "-" != -1 ? -1 : 1
    msg.reply report [rollOne(6, offset)]
  robot.respond /roll dice(\s?\+\s?(\d+))?/i, (msg) ->
    variant = msg.match[1] or= "+"
    offset = parseInt msg.match[2] or= 0 * variant.indexOf "-" != -1 ? -1 : 1
    msg.reply report roll 2, 6, offset
  robot.respond /roll (\d+)d(\d+)(\s?\+\s?(\d+))?/i, (msg) ->
    dice = parseInt msg.match[1]
    sides = parseInt msg.match[2]
    variant = msg.match[3] or= "+"
    offset = parseInt msg.match[4] or= 0 * variant.indexOf "-" != -1 ? -1 : 1
    answer = if sides < 1
      "I don't know how to roll a zero-sided die."
    else if dice > 100
      "I'm not going to roll more than 100 dice for you."
    else
      report roll dice, sides, offset
    msg.reply answer

report = (results) ->
  if results?
    switch results.length
      when 0
        "I didn't roll any dice."
      when 1
        "I rolled a #{results[0]}."
      else
        total = results.reduce (x, y) -> x + y
        finalComma = if (results.length > 2) then "," else ""
        last = results.pop()
        "I rolled #{results.join(", ")}#{finalComma} and #{last}, making #{total}."

roll = (dice, sides, offset) ->
  rollOne(sides, offset) for i in [0...dice]

rollOne = (sides, offset) ->
  1 + Math.floor(Math.random() * sides) + offset
