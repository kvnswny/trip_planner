require 'httparty'
require 'cgi'

class TripPlanner
	attr_reader :user, :forecast, :recommendation

	def initialize
	end

	def plan
		self.create_user
		self.get_forecast
		self.show_forecast
		self.packing_list
	end

	def create_user
		# puts("What is your name?")
		# @name = gets().chomp()
		# puts("Which city?")
		# @city = CGI.escape(gets().chomp())
		# puts("How many days?")
		# @days = gets().chomp().to_i
		@name = "Sasha Banks"
		@city = CGI.escape("Nome, AK")
		@days = 3
		@user = User.new(@name, @city, @days)
	end

	def get_forecast
		options = "daily?q=#{@city}&mode=json&units=imperial&cnt=#{@days}"
		@forecasts = HTTParty.get("http://api.openweathermap.org/data/2.5/forecast/#{options}")
		@city = @forecasts['city']['name']
	end

	def show_forecast
		@trip_min = 999
		@trip_max = -999
		conditions = Array.new()
		puts("#{@name}, here is your forecast:")
		i = 0
		while i < @days
			date = (Time.at(@forecasts['list'][i]['dt'])).to_date
			@condition = (@forecasts['list'][i]['weather'][0]['description']).downcase
			min = (@forecasts['list'][i]['temp']['min']).round
			@trip_min = min if min < @trip_min
			max = (@forecasts['list'][i]['temp']['max']).round
			@trip_max = max if max > @trip_max
			conditions.push(@condition)
			puts("On #{date}, #{@city} will have #{@condition}, high of #{max} and low of #{min}.")
			i += 1
		end
		conditions = conditions.uniq
	end

	def packing_list
		packing_list = Array.new
		j = 0
		while j < CLOTHES.length
			packing_list << CLOTHES[j][0][:bring]
			j += 1
		end
		puts packing_list
	end

	CLOTHES =
	[
		{min_temp: -50, max_temp: 0, bring: [
			"parka", "fleece", "gloves", "scarf"]
		}
	],
	[
		{min_temp: 75, max_temp: 110, bring: [
				"shorts", "flip-flops", "sunglasses"]
		}
	]

end

class User
	attr_reader :name, :city, :days

	def initialize(name, city, days)
	end
end

trip_plan = TripPlanner.new
trip_plan.plan
