require 'uri'
require 'net/http'
require 'json'

class Weather < ApplicationService
  def initialize(location)
    @location = location
  end

  def call
    deleted_forecasts = @location.forecasts.map do |forecast|
      forecast.delete if forecast.date < Date.new
    end
    
    return if not deleted_forecasts

    weather = get_weather(@location.latitude, @location.longitude)

    weather["daily"]["time"].each_with_index do |date, index|
      forecast = @location.forecasts.find_or_initialize_by(date: date)
      forecast.max_temp = weather["daily"]["temperature_2m_max"][index]
      forecast.min_temp = weather["daily"]["temperature_2m_min"][index]
      forecast.save!
    end
  end

  private

    def get_weather(lat, long)
      weather = Net::HTTP.get(URI("https://api.open-meteo.com/v1/forecast?latitude=#{lat}&longitude=#{long}&daily=temperature_2m_max,temperature_2m_min&temperature_unit=fahrenheit"))
      JSON.parse(weather)
    end
end