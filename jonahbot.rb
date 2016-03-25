#Jonah's Discord Bot!

require 'discordrb'
require 'open-uri'
require 'json'

bot = Discordrb::Commands::CommandBot.new 'User@Email', 'Password', '!'

html = open('https://global.api.pvp.net/api/lol/static-data/na/v1.2/champion?api_key=a75795cb-cdc6-4f44-9d16-386c8d00b7ad', 'User-Agent' => 'Ruby').read

response = JSON.parse(html)
response = response["data"]
champs = []

response.each { |champ, value| champs.push(champ) }


bot.command :hi do |event|
	"Hello " + event.user.name + "!"
end

bot.command(:randomroles, min_args: 1, max_args: 5) do |_event, *args|
	
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

bot.command :isawesome do |event, arg|

	if arg == "jonah" || arg == "Jonah"
		event << "Absolutely"
	else 
		event << "Nope"
	end

end


bot.run


