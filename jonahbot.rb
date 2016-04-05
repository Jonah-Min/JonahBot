#Jonah's Discord Bot!

require 'discordrb'
require 'open-uri'
require 'json'
require 'nokogiri'

# creates new random number generator
r = Random.new

# initialize bot
# in order to start the bot, it requries a discord account
# the first argument is the email used to create the account
bot = Discordrb::Commands::CommandBot.new 'username@email.com', 'password', '!'

# grab all champions from league of legends api for league commands
# Requires account on riot games as well as an api key found at developer.riotgames.com
html = open('https://global.api.pvp.net/api/lol/static-data/na/v1.2/champion?api_key= GET YOURS AT developer.riotgames.com', 'User-Agent' => 'Ruby').read

response = JSON.parse(html)
response = response["data"]
champs = []

response.each { |champ, value| champs.push(champ) }

# Checks for new members joinging the discord channel
bot.member_join do |event|
	event.server.general_channel.send_message("#{:member} joined this server!")
end

# Once it can take commands it will print message to send to channel
# Requires discord's code for your channel
bot.ready do 
	bot.send_message('channel code', "\n Jonah Bot is up and running! \n\n Type !commands for a list of available commands  ^ ^")
end

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

	# Only parses first page of results
	if number > 25 || number < 1
		_event.respond "Number of posts must be between 1 and 25"
	end

	# The only categories of reddit (I believe)
	if category != 'rising' && category != 'hot' && category != 'new' && category != 'controversial'
		_event.respond "Invalid Input!"
	end

	# Sets up reddit url
	if category.downcase == 'hot'
		url = "https://www.reddit.com/r/" + args[0] + ".json"
	else
		url = "https://www.reddit.com/r/" + args[0] + "/" + args[1] + "/.json"
	end

	# Opens reddit url
	# Uses user agent in order to make calls
	html = open(url, 'User-Agent' => 'Discord Bot by u/input username').read
	response = JSON.parse(html)

	response = response["data"]["children"]

	titles = []
	urls = []

	response.each do |child|

		# Grabs title of post and it's data type (selftext or link)
		titles.push(child["data"]["title"])
		selftext = child["data"]["selftext"]

		# Returns url if not selftext post
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

# Random number generator
bot.command :roll do |event, arg|
	r.rand(arg.to_i)
end

# Random Coin flip, wierd bug, working on a fix
bot.command :coin do |event|
	coin = r.rand(2)

	event << ''

	if coin == 0
		event << "heads"
	else
		event << "tails"
	end
end

# Anime list searcher
bot.command :anime do |event, *args|

	# Sets up link for API
	anime = ''
	args.each do |str|
		anime = anime + str + '+'
	end
	anime = anime[0...-1]
	anime.gsub(' ', '+')
	url = "http://myanimelist.net/api/anime/search.xml?q=" + anime

	# Grabs data using XML parser Nokogiri
	# Requires My Anime List account to access the api
	doc = Nokogiri::XML(open(url, http_basic_authentication: ["MAL username", "MAL password"]))

	# Parses through all data of first entry (Some have multiple entries)
	doc.xpath('//entry').each do |entry|

		event.respond entry.xpath('image').text

		response = "\n\n" + entry.xpath('title').text + "\n" + entry.xpath('english').text + "\n\n"
		response = response + "Score : " + entry.xpath('score').text + "\n\n"
		response = response + "Type : " + entry.xpath('type').text + "\n\n"
		response = response + "Episodes : " + entry.xpath('episodes').text + "\n\n"
		response = response + "Status : " + entry.xpath('status').text + "\n\n"

		end_date = entry.xpath('end_date').text

		# If manga is ongoing then the date will be 0000-00-00
		if end_date == "0000-00-00"
			end_date = "On-Going"
		end

		response = response + "Aired : " + entry.xpath('start_date').text + " - " + end_date + "\n\n"
		response = response + "Synopsis : \n" + entry.xpath('synopsis').text.gsub('<br />', "")

		event.respond response
		break
	end

end

# Manga API information bot
bot.command :manga do |event, *args|

	# Sets up URL
	manga = ''
	args.each do |str|
		manga = manga + str + '+'
	end
	manga = manga[0...-1]
	manga.gsub(' ', '+')
	url = "http://myanimelist.net/api/manga/search.xml?q=" + manga

	# Uses Nokogiri to parse XML 
	# Requires My Anime List account to access the api
	doc = Nokogiri::XML(open(url, http_basic_authentication: ["MAL username", "MAL password"]))

	# Grabs all data from first entry
	doc.xpath('//entry').each do |entry|

		event.respond entry.xpath('image').text

		response = "\n\n" + entry.xpath('title').text + "\n" + entry.xpath('english').text + "\n\n"
		response = response + "Score : " + entry.xpath('score').text + "\n\n"
		response = response + "Chapters : " + entry.xpath('chapters').text + "\n\n"
		response = response + "Volumes : " + entry.xpath('volumes').text + "\n\n"
		response = response + "Status : " + entry.xpath('status').text + "\n\n"

		end_date = entry.xpath('end_date').text

		# If manga is ongoing then the date will be 0000-00-00
		if end_date == "0000-00-00"
			end_date = "On-Going"
		end

		response = response + "Aired : " + entry.xpath('start_date').text + " - " + end_date + "\n\n"
		response = response + "Synopsis : \n" + entry.xpath('synopsis').text.gsub('<br />', "")

		event.respond response
		break
	end

end

# Champion data scraper from champion.gg
bot.command :stats do |event, *args|

	# Name may have spaces
	counter = 0
	champion = ''
	while counter < args.size() - 1
		champion = champion + args[counter]
		counter = counter + 1
	end

	if champion == 'wukong'
		champion = 'monkeyking'
	end

	role = args[-1]

	# ADC and Middle has a few different representations
	if role == 'marksman' || role == 'bot'
		role = "adc"
	elsif role == 'mid'
		role = "middle"
	end

	url = "http://champion.gg/champion/" + champion + "/" + role

	# Nokogiri html parser
	doc = Nokogiri::HTML(open(url, "User-Agent" => "Discord Bot"))

	event << ""
	event << doc.css("li[class='selected-role'] h3").text.strip
	event << doc.css("li[class='selected-role']  small")[0].text.strip + " Out of" + doc.css("li[class='selected-role'] small")[1].text
	event << "Win-Rate : " + doc.css("tr[id='statistics-win-rate-row'] td")[1].text
	event << "Play-Rate : " + doc.css("tr[id='statistics-play-rate-row'] td")[1].text 

end

# Random Gif generator based of keywords search
bot.command :gif do |event, *args|

	search = ''
	args.each do |str|
		search = search + str + '+'
	end
	search = search[0...-1]

	# Uses public API Beta key will apply for official key
	url = "http://api.giphy.com/v1/gifs/search?q=" + search + "&api_key=dc6zaTOxFJmzC"

	html = open(url, 'User-Agent' => 'Discord Bot by u/QuantumBogo').read
	response = JSON.parse(html)

	# Response has any number of gifs for each keyword
	# I choose one at random
	data = response['data']
	count = data.size()
	random = r.rand(count)
	counter = 0

	data.each do |child|

		if counter == random
			event.respond child["url"]
			break
		end

		counter = counter + 1

	end

end

# Pokemon API just a little information
bot.command :pokedex do |event, arg|

	url = "http://pokeapi.co/api/v2/pokemon/" + arg
	doc = open(url, "User-Agent" => "Discord Bot").read
	response = JSON.parse(doc)

	types = []

	response['types'].each do |type|
		types.push(type['type']['name'])
	end

	event.respond response["sprites"]["front_default"]

	message = "\nType: "

	for i in 0..(types.size() - 1)
		message = message + types[i].capitalize + " "
	end

	message = message + "\n\nIn Games:\n\n"

	games = []

	response["game_indices"].each do |game|
		games.push(game["version"]["name"].gsub("-", " ").capitalize)
	end

	for i in 0..(games.size() - 1)
		message = message + games[i] + "\n"
	end

	message

end

# just tells users about different commands
bot.command :commands do |event|
	event << ""
	event << "!hi  - Gives you a friendly greeting ^ ^"
	event << "!randomroles [Names]  - Given between 2 to 5 names it chooses random league roles for them"
	event << "!randomchampion [Number  between 1 - " + champs.size().to_s + "]  - Gives you a number of random champions"
	event << "!roll [Number]  - Gives you a random number between given number"
	event << "!coin  - Returns heads or tails"
	event << "!stats [Champion, Role] - Returns Stats for champion in given role, if no data from that role, defaults to most played role"
	event << "!reddit [Subreddit, Category, Number]  - Givens certain number of posts on subreddit by category"
	event << "!anime [Anime]  - Gives information for the given anime"
	event << "!manga [Manga]  - Gives information for the given manga"
	event << "!gif [Keywords]  - Finds gif under given keywords"
	event << "!pokedex [Pokemon]  - Finds Pokemon's image and gives infromation about what games it's from \n\n"
	event << "Jonah is the best bot creator"
end

bot.run

