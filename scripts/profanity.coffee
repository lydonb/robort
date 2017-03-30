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
    robot.karma.increment swearJar, punisher for [1..count]
    msg.send "#{swearJar} #{robot.karma.incrementResponse()} (Karma: #{robot.karma.get(swearJar)})"

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
        'tit',
        'tits',
        'titties',
        'titty'
    ]
    regex = new RegExp('\\b(' + words.join('|') + '|\\w*fuck\\w*)\\b', 'ig');

    robot.hear regex, (msg) ->
      punish robot, msg, 'swearjar', 'robort', msg.message.text.match(regex).length or= 1
