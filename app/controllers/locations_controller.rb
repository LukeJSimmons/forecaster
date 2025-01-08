require 'net/http'
require 'json'

class LocationsController < ApplicationController
  before_action :require_login

  def new
    @location = Location.new
  end

  def create
  end

  def show
    @location = Location.find_by(id: params[:id])

    unless @location
      loc = get_location
      @location = Location.create!(city: loc["city"], region: loc["region_code"], country: loc["country"], user_id: current_user.id)
    end

    weather = get_weather(loc)

    weather["daily"]["time"].each_with_index do |date, index|
      Forecast.create!(date: date, max_temp: weather["daily"]["temperature_2m_max"][index], min_temp: weather["daily"]["temperature_2m_min"][index], location_id: @location.id)
    end
  end

  private

    def require_login
      unless user_signed_in?
        flash[:alert] = "You must be logged in to access this section."
        redirect_to new_user_session_path
      end
    end

    def get_location
      loc = Net::HTTP.get(URI('https://ipapi.co/json/'))
      return JSON.parse(loc)
    end

    def get_weather(loc)
      weather = Net::HTTP.get(URI("https://api.open-meteo.com/v1/forecast?latitude=#{loc["latitude"]}&longitude=#{loc["longitude"]}&daily=temperature_2m_max,temperature_2m_min&temperature_unit=fahrenheit"))
      JSON.parse(weather)
    end
end
