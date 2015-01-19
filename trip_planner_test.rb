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
	end

	def create_user
		puts("What is your name?")
		@name = gets().chomp()
		puts("Which city?")
		@city = CGI.escape(gets().chomp())
		puts("How many days?")
		@days = gets().chomp().to_i
		@user = (User.new(@name, @city, @days)).to_s
	end

	def get_forecast
		options = "daily?q=#{@city}&mode=json&units=imperial&cnt=#{@days}"
		@forecasts = HTTParty.get("http://api.openweathermap.org/data/2.5/forecast/#{options}")
		@city = @forecasts['city']['name']
	end

	def show_forecast
		puts("#{user}, here is your forecast:")
		i = 0
		while i < @days
			date = (Time.at(@forecasts['list'][i]['dt'])).to_date
			condition = (@forecasts['list'][i]['weather'][0]['description']).downcase
			min = @forecasts['list'][i]['temp']['min']
			max = @forecasts['list'][i]['temp']['max']
			puts("On #{date}, conditions in #{@city} will have #{condition}, high of #{max} and low of #{min}.")
			i += 1
		end
	end

end

class User
	attr_reader :name, :city, :days

	def initialize(name, city, days)
	end
end

trip_plan = TripPlanner.new
trip_plan.plan

# puts("What is your name?")
# name = gets().chomp()
# puts("Which city?")
# city = CGI.escape(gets().chomp())
# puts("How many days?")
# days = gets().chomp().to_i
# user = User.new(name, city, days)

# options = "daily?q=#{city}&mode=json&units=imperial&cnt=#{days}"
# forecasts = HTTParty.get("http://api.openweathermap.org/data/2.5/forecast/#{options}")
# city = forecasts['city']['name']


# puts("#{user}, here is your forecast:")
# i = 0
# while i < days
# 	date = Time.at(forecasts['list'][i]['dt'])
# 	condition = (forecasts['list'][i]['weather'][0]['main']).downcase
# 	min = forecasts['list'][i]['temp']['min']
# 	max = forecasts['list'][i]['temp']['max']
# 	puts("#{date} in #{city} will be #{condition}, with a high of #{max} and a low of #{min}.")
# 	i += 1
# end
