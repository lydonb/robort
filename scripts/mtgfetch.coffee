# Description:
#   Fetches MTG image and card information. 
#	These names need to be an exact match. 
#
# Configuration:
#   None
#
# Commands:
#	robort mtgme <card>
#
# Author:
#   mickey

module.exports = (robot) ->

  robot.respond /mtgme (.*)/i, (msg) ->
  	cardname = escape(msg.match[1])
  	robot.http("https://api.magicthegathering.io/v1/cards?name=#{cardname}")
  		.get() (err, res, body) -> 
  			json = JSON.parse(body)
  			isEmpty = json?
  			try
  				json = JSON.parse(body)
  				imageUrl = json.cards[1].imageUrl
  				msg.send "#{imageUrl} and #{isEmpty}"
  			catch error
  				#msg.send "Card #{cardname} not found."
  				msg.send "#{imageUrl} and #{isEmpty}"

# If more than one card check if prerelease
	# if prerelease ignore and check next card
	# if next card has imageUrl then get imageUrl
	# If imageUrl not there then print the default information. 
# Default information
#	Name
#	Converted Mana Cost
#	Oracle Text
#	Flavor Text
#	Power/Toughness
