# Write your soltuion here!

require "http"
require "json"
require "dotenv/load"

weather_key = ENV.fetch("WEATHER_KEY")
maps_key = ENV.fetch("MAPS_KEY")

puts "--------------------------------\nWill you need an umbrella today?\n--------------------------------"

puts "Where are you?"
raw_location = gets

puts "Checking the weather at #{raw_location.capitalize}..."

location = raw_location.downcase.chomp

# Build Maps API request url

address_url = location.gsub(" ","%20")
maps_req = "https://maps.googleapis.com/maps/api/geocode/json?address=#{address_url}&key=#{maps_key}"

# Send Maps API request

raw_maps = HTTP.get(maps_req).to_s

json_maps = JSON.parse(raw_maps)

# to show JSON: pp json_maps

# Find coordinate in JSON response

coordinate = json_maps.fetch("results").at(0).fetch("geometry").fetch("location")

latitude = coordinate.fetch("lat").to_s
longitude = coordinate.fetch("lng").to_s

puts "Your coordinates are #{latitude}, #{longitude}."

# Build Weather API Request URL

weather_req = "https://api.pirateweather.net/forecast/#{weather_key}/#{latitude},#{longitude}"

# Send Weather API Request

raw_weather = HTTP.get(weather_req).to_s

json_weather = JSON.parse(raw_weather)

now_temp = json_weather.fetch("currently").fetch("temperature")

puts "It is currently #{now_temp}°F."

next_hour = json_weather.fetch("minutely", false)

if next_hour
  next_hour_summary = next_hour.fetch("summary")
  puts "Next hour: #{next_hour_summary}."
end

hourly_data = json_weather.fetch("hourly").fetch("data")

total = 0

hourly_data[2..13].each do |hour|
  time = (Time.at(hour.fetch("time"))-Time.now)/60/60
  prob = hour.fetch("precipProbability")
  if prob >= 0.1
    total = total + 1
    puts "In #{time.round} hours, there is a #{(prob*100).to_i}% chance of precipitation."
  end
end

if total > 0
  puts "You might want to carry an umbrella!"
else
  puts "You probably won\'t need an umbrella today."
end
