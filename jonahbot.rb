#Jonah's Discord Bot!

require 'discordrb'
require 'open-uri'
require 'json'

# creates new random number generator
r = Random.new

# initialize bot
bot = Discordrb::Commands::CommandBot.new 'email@website.com', 'password', '!'

# grab all champions from league of legends api for league commands
html = open('https://global.api.pvp.net/api/lol/static-data/na/v1.2/champion?api_key=a75795cb-cdc6-4f44-9d16-386c8d00b7ad', 'User-Agent' => 'Ruby').read

response = JSON.parse(html)
response = response["data"]
champs = []

response.each { |champ, value| champs.push(champ) }

# Says hello to the user 
bot.command :hi do |event|
	"Hello " + event.user.name + "!"
end

# Chooses random league of legends roles for all of the given names, minimum of 2
bot.command(:randomroles, min_args: 2, max_args: 5) do |_event, *args|
	
	roles = ['Top:   ', 'Jung:  ', 'Mid:   ', 'ADC:  ', 'Supp:  ']
	roles.shuffle!

	args.shuffle!

	size = args.size()
	counter = 0

	_event << ''

	while counter < size
		_event << roles[counter] + args[counter]
		counter = counter + 1
	end

end

# Selects a random number of champions that you specify
bot.command(:randomchampion, min_args: 1, max_args: 1) do |_event, arg|

	_event << ''

	count = arg.to_i
	counter = 0

	if count > champs.size() || count < 0
		_event << "Invalid Input!"
	else
		while counter < count
			_event << champs.sample
			counter = counter + 1
		end
	end

end

# Given a subreddit, category, and a number of posts, responds with number of posts
bot.command(:reddit, min_args: 3, max_args: 3) do |_event, *args|

	subreddit = args[0]
	category = args[1]
	number = args[2].to_i

	if number > 25 || number < 1
		_event.respond "Number of posts must be between 1 and 25"
	end

	if category != 'rising' || category != 'hot' || category != 'new' || category != 'controversial'
		_event.respond "Invalid Input!"
	end

	# Sets up reddit url
	if category.downcase == 'hot'
		url = "https://www.reddit.com/r/" + args[0] + ".json"
	else
		url = "https://www.reddit.com/r/" + args[0] + "/" + args[1] + "/.json"
	end

	# Opens reddit url
	html = open(url, 'User-Agent' => 'Discord Bot by u/QuantumBogo').read
	response = JSON.parse(html)

	response = response["data"]["children"]

	titles = []
	urls = []

	response.each do |child|
		titles.push(child["data"]["title"])
		selftext = child["data"]["selftext"]

		if selftext == ''
			urls.push(child["data"]["url"])
		else
			# This package doesn't allow for strings of over 2000 characters
			if selftext.length < 2000
				urls.push(child["data"]["selftext"])
			else
				urls.push(child["data"]["url"])
			end
		end
	end

	counter = 0

	while counter < number
		_event.respond "\n" + titles[counter] + "\n\n" + urls[counter] + "\n"
		counter = counter + 1
	end

end

bot.command :roll do |event, arg|
	event.respond r.rand(arg.to_i)
end

bot.command :coin do |event|
	coin = r.rand(1)

	event << ''

	if coin == 0
		event << "heads"
	else
		event << "tails"
	end
end

bot.command :commands do |event|
	event << ""
	event << "!randomroles [names]  - Given between 2 to 5 names it chooses random league roles for them"
	event << "!hi  - Gives you a friendly greeting ^ ^"
	event << "!randomchampion [number]  - Gives you a number of random champions"
	event << "!roll [number]  - Gives you a random number between given number"
	event << "!coin  - Returns heads or tails"
	event << "!reddit [subreddit, category, number]  - Givens certain number of posts on subreddit by category \n\n"
	event << "Jonah is the best bot creator"
end

bot.run


