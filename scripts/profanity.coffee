# Description:
#   Watch your language!
#
# Dependencies:
#   "underscore": ""
#
# Configuration:
#   None
#
# Commands:
#
# Author:
#   whitman, mjknowles
#
# Retrieved on 2015-06-03 from https://github.com/github/hubot-scripts/blob/master/src/scripts/demolition-man.coffee
#

#karma = require './karma'

punish = (robot, msg, swearJar, punisher, count) ->
  responses = (robot.karma.increment swearJar, punisher, 'profanity' for [1..count])
  msg.send "@#{punisher} added #{responses.length} #{if responses.length > 1 then 'points' else 'point'} to #{swearJar}! (Total: #{robot.karma.get(swearJar)})"

module.exports = (robot) ->
    words = [
        'ass',
        'asshole',
        'assholes',
        'bastard',
        'bastards',
        'bitch',
        'bitches',
        'bitchtits',
        'bullshit',
        'cock',
        'cocks',
        'cocksucker',
        'cocksuckers',
        'cunt',
        'cunts',
        'dammit',
        'damn',
        'damned',
        'damnit',
        'dick',
        'dicks',
        'fag',
        'fags',
        'goddamn',
        'hell',
        'horseshit'
        'piss',
        'shit',
        'shits',
        'shitter',
        'shithole',
        'shitty',
        'shitting',
        'tit',
        'tits',
        'titties',
        'titty'
    ]
    regex = new RegExp('\\b(' + words.join('|') + '|\\w*fuck\\w*)\\b', 'ig');

    robot.hear regex, (msg) ->
      punish robot, msg, 'swearjar', msg.message.user.name, msg.message.text.match(regex).length or= 1
