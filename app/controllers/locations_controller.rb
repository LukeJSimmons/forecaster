require 'net/http'
require 'uri'
require 'json'

class LocationsController < ApplicationController
  def new
    @location = Location.new
  end

  def create
    @location = Location.new(location_params)

    coordinates = parse_location

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

    if @location.is_current_location
      current_location = get_current_location
      @location.update(city: current_location["city"], region: current_location["region"], country: current_location["country"])
      coordinates = parse_location

      @location.longitude = coordinates["longt"]
      @location.latitude = coordinates["latt"]
    end

    generate_forecasts
    generate_chart_url

    @location.save
  end

  def index
    @locations = Location.all

    if @locations == []
      current_location = get_current_location
      Location.create!(city: current_location["city"], region: current_location["region"], country: current_location["country"], is_current_location: true)
    end
  end

  def destroy
    @location = Location.find(params[:id])
    @location.destroy

    redirect_to locations_path
  end

  private

    def parse_location
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

    def get_current_location
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
        forecast = @location.forecasts.find_or_initialize_by(date: date)
        forecast.max_temp = weather["daily"]["temperature_2m_max"][index]
        forecast.min_temp = weather["daily"]["temperature_2m_min"][index]
        forecast.save!
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
      params.require(:location).permit(:city, :region, :country, :latitude, :longitude, :chart_url)
    end
end
