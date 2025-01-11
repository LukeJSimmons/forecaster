require 'net/http'
require 'uri'
require 'json'

class LocationsController < ApplicationController
  before_action :require_login

  def new
    @location = Location.new
  end

  def create
    @location = Location.new(location_params)
    @location.user_id = current_user.id

    coordinates = parse_location(params)

    @location.longitude = coordinates["longt"]
    @location.latitude = coordinates["latt"]

    if @location.save
      generate_forecasts
      generate_chart_url
      @location.save
      
      redirect_to @location
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @location = Location.find(params[:id])
  end

  def index
    @locations = Location.all

    unless @locations != []
      loc = get_location
      @location = Location.create!(city: loc["city"], region: loc["region_code"], country: loc["country"], latitude: loc["latitude"], longitude: loc["longitude"], user_id: current_user.id)
      @locations = Location.all
    end
  end

  def destroy
    @location = Location.find(params[:id])
    @location.destroy

    redirect_to locations_path
  end

  private

    def require_login
      unless user_signed_in?
        flash[:alert] = "You must be logged in to access this section."
        redirect_to new_user_session_path
      end
    end

    def parse_location(params)
      uri = URI('https://geocode.xyz')

      uri_params = {
          'auth' => '205947941065469632418x93807 ',
          'locate' => "#{@location.city} #{@location.region} #{@location.country}",
          'geoit' => 'json'
      }

      uri.query = URI.encode_www_form(uri_params)

      response = Net::HTTP.get(uri)
      JSON.parse(response)
    end

    def get_location
      loc = Net::HTTP.get(URI('https://ipapi.co/json/'))
      return JSON.parse(loc)
    end

    def get_weather(lat, long)
      weather = Net::HTTP.get(URI("https://api.open-meteo.com/v1/forecast?latitude=#{lat}&longitude=#{long}&daily=temperature_2m_max,temperature_2m_min&temperature_unit=fahrenheit"))
      JSON.parse(weather)
    end
    
    def generate_forecasts
      weather = get_weather(@location.latitude, @location.longitude)

      weather["daily"]["time"].each_with_index do |date, index|
        Forecast.create!(date: date, max_temp: weather["daily"]["temperature_2m_max"][index], min_temp: weather["daily"]["temperature_2m_min"][index], location_id: @location.id)
      end
    end

    def generate_chart_url
      dates = []
      min_temps = []
      max_temps = []

      @location.forecasts.each do |forecast|
        dates << forecast.date.strftime("%A")
        max_temps << forecast.max_temp
        min_temps << forecast.min_temp
      end

      @location.chart_url = "https://image-charts.com/chart?cht=lc&chd=t:#{max_temps.join(',')}|#{min_temps.join(',')}&chl=#{max_temps.join('|')}|#{min_temps.join('|')}&chlps=align,50&chs=700x350&chxt=x,y&chxl=0:|#{dates.join('|')}&chdl=High|Low&chdlp=t&chco=a51d2a,0250c4"
    end

    def location_params
      params.require(:location).permit(:city, :region, :country, :latitude, :longitude, :chart_url, :user_id)
    end
end
