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
#   @bot show profanity - Show your profanity score
#   @bot show profanity <username> - Show the user's profanity score
#
# Author:
#   whitman, mjknowles
#
# Retrieved on 2015-06-03 from https://github.com/github/hubot-scripts/blob/master/src/scripts/demolition-man.coffee
#

#karma = require './karma'

punish = (robot, msg, karmaWord, punisher) ->
    #k = new karma.Karma robot
    robot.karma.increment karmaWord, punisher
    msg.send "#{karmaWord} #{robot.karma.incrementResponse()} (Karma: #{robot.karma.get(karmaWord)})"

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
        'fuck',
        'fucks',
        'fucked',
        'fucker',
        'fuckers',
        'fucking',
        'goddamn',
        'hell',
        'horseshit'
        'motherfucker'
        'motherfuckers',
        'motherfucking'
        'piss',
        'shit',
        'tit',
        'tits',
        'titties',
        'titty'
    ]
    regex = new RegExp('(?:^|\\s)(' + words.join('|') + ')(?:\\s|\\.|\\?|!|$)', 'ig');

    robot.hear regex, (msg) ->
      punish robot, msg, 'swearjar', 'nestle'
