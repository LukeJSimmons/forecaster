require 'net/http'
require 'json'

class LocationController < ApplicationController
  def new
    loc = Net::HTTP.get(URI('https://ipapi.co/json/'))
    json = JSON.parse(loc)
    
    @location = Location.create!(city: json["city"], region: json["region_code"], country: json["country"], user_id: current_user.id)

    weather = Net::HTTP.get(URI("https://api.open-meteo.com/v1/forecast?latitude=#{json["latitude"]}&longitude=#{json["longitude"]}&daily=temperature_2m_max,temperature_2m_min&temperature_unit=fahrenheit"))
    weather_json = JSON.parse(weather)

    weather_json["daily"]["time"].each_with_index do |date, index|
      Forecast.create!(date: date, max_temp: weather_json["daily"]["temperature_2m_max"][index], min_temp: weather_json["daily"]["temperature_2m_min"][index], location_id: @location.id)
    end
  end

  def create
  end
end
