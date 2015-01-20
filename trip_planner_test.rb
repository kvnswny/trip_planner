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
		puts("What is your name?")
		@name = gets().chomp()
		puts("Which city?")
		@city = CGI.escape(gets().chomp())
		puts("How many days?")
		@days = gets().chomp().to_i
		# @name = "Nameford G. Namington"
		# @city = CGI.escape("Miami, FL")
		# @days = 3
		# @user = User.new(@name, @city, @days)
	end

	def get_forecast
		options = "daily?q=#{@city}&mode=json&units=imperial&cnt=#{@days}"
		@forecasts = HTTParty.get("http://api.openweathermap.org/data/2.5/forecast/#{options}")
		@city = @forecasts['city']['name']
	end

	def show_forecast
		@trip_min = 999
		@trip_max = -999
		@conditions = Array.new()
		puts("#{@name}, here is your forecast:")
		i = 0
		while i < @days
			date = (Time.at(@forecasts['list'][i]['dt'])).to_date
			@condition = (@forecasts['list'][i]['weather'][0]['description']).downcase
			min = (@forecasts['list'][i]['temp']['min']).round
			@trip_min = min if min < @trip_min
			max = (@forecasts['list'][i]['temp']['max']).round
			@trip_max = max if max > @trip_max
			@conditions.push(@condition)
			puts("On #{date}, #{@city} will have #{@condition}, high of #{max} and low of #{min}.")
			i += 1
		end
		@conditions = @conditions.uniq
	end

	def packing_list
		packing_list = Packing_list.new(@trip_max, @trip_min, @conditions)
		packing_list.pack
	end
end



class Packing_list
	attr_reader :trip_max, :trip_min, :conditions

	def initialize(trip_max, trip_min, conditions)
		@trip_max = trip_max
		@trip_min = trip_min
		@conditions = conditions
	end

	def pack
		packing_list = Array.new
		j = 0
		while j < CLOTHES.length
			if ( (@trip_min > CLOTHES[j][0][:min_temp]) && (@trip_min < CLOTHES[j][0][:max_temp]) )
				packing_list << CLOTHES[j][0][:bring]
			end
			if ( (@trip_max < CLOTHES[j][0][:max_temp]) && (@trip_max > CLOTHES[j][0][:min_temp]) )
				packing_list << CLOTHES[j][0][:bring]
			end
			j += 1
		end
		packing_list = (packing_list.uniq)
		puts CLOTHES.length
		puts "The temperature will range from #{@trip_min} to #{trip_max}.  You should bring #{packing_list}"
	end

	CLOTHES =
	[
		{min_temp: -50, max_temp: 0, bring: [
			"heavy coat", "face mask", "mittens", "fleece-lined jeans"]
		}
	],
	[
		{min_temp: 0, max_temp: 32, bring: [
			"gloves", "coat", "sweatshirt"]
		}
	],
	[
		{min_temp: 70, max_temp: 100, bring: [
			"shorts", "flip-flops", "sunglasses"]
		}
	],
	[
		{min_temp: 100, max_temp: 999, bring: [
			"that suit that Mr. Freeze has"]
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
