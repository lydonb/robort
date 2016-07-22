# Description:
#   Fetches MTG image and card information. 
#	These names need to be an exact match. 
#
#	I love me some apostrophes. This is v0.01
#
# Configuration:
#   None
#
# Commands:
#	robort mtgme <card>
#
# Future ideas:
#	robort mtgme -t <card>
#	This only prints the card text, no image. 
#
# Author:
#   mickey

module.exports = (robot) ->
  robot.respond /mtgme (.*)/i, (msg) ->
  	# Get the card
  	cardname = msg.match[1]
  	
  	# Check for apostrophe
  	hasApostrophe = cardname.indexOf('\'') >= 0
  	if hasApostrophe 
  		robot.http("""https://api.magicthegathering.io/v1/cards?name=#{cardname}""")
	  		.get() (err, res, body) -> 
	  			json = JSON.parse(body)
	  			numCards = Object.keys(json.cards).length

	  			# Check if there isn't an exact match
	  			# Do a little cheating here
	  			# Make a map for the card name
	  			sameArray = {}
	  			sameArray[cardname] = 0
	  			for card in json.cards
	  				sameArray[card.name]++

	  			# Check if there are multiple cards that do not include promo or gameday
	  			if(numCards > 1 && sameArray[cardname] != numCards)
	  				msg.send '''
	  					Please be more specific:
	  				'''
	  				msg.send card.name for card in json.cards
	  			# If there is an exact match for a card name
	  			else if (sameArray[cardname] == numCards)					
		  			try
		  				msg.send card.imageUrl for card in json.cards when card.set isnt 'pPRE' && card.set isnt 'pMGD' 
		  			catch error
		  				msg.send "Card #{cardname} not found."
		  		else
		  			msg.send "This shouldn't happen..."

  	# Else no apostrophe
  	else
  		cardname = '\"' + cardname + '\"'
  		#msg.send """https://api.magicthegathering.io/v1/cards?name=#{cardname}"""
  		robot.http("""https://api.magicthegathering.io/v1/cards?name=#{cardname}""")
	  		.get() (err, res, body) -> 
	  			json = JSON.parse(body)
	  			numCards = Object.keys(json.cards).length

	  			# Check if there isn't an exact match
	  			if numCards > 0
	  				# Return first card that has an imageUrl.
	  				for card in json.cards
	  					if card.imageUrl? 
	  						msg.send card.imageUrl
	  						break

	  			else
	  				msg.send "Card #{cardname} not found."


# Personal notes don't mind me:
# If there is an apostrophe, don't do exact matching
# Else do exact matching. 
# If more than one card check if prerelease / game day promo
	# if prerelease ignore and check next card
	# if next card has imageUrl then get imageUrl
	# If imageUrl not there then print the default information. (future version)
# Default information
#	Name
#	Converted Mana Cost
#	Oracle Text
#	Flavor Text
#	Power/Toughness
