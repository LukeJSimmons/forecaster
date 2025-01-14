require "net/http"
require "uri"
require "json"

include LocationHelper

class LocationsController < ApplicationController
  def new
    @location = Location.new
  end

  def create
    @location = Location.new(location_params)

    coordinates = parse_location(@location)

    @location.longitude = coordinates["longt"]
    @location.latitude = coordinates["latt"]

    if @location.save
      generate_forecasts(@location)
      @location.chart_url = generate_chart_url(@location)
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
      coordinates = parse_location(@location)

      @location.longitude = coordinates["longt"]
      @location.latitude = coordinates["latt"]
    end

    generate_forecasts(@location)
    @location.chart_url = generate_chart_url(@location)

    @location.save
  end

  def index
    if Location.all == []
      current_location = get_current_location
      Location.create!(city: current_location["city"], region: current_location["region"], country: current_location["country"], is_current_location: true)
    end

    @locations = Location.all
  end

  def destroy
    @location = Location.find(params[:id])
    @location.destroy

    redirect_to locations_path
  end

  private

    def location_params
      params.require(:location).permit(:city, :region, :country, :latitude, :longitude, :chart_url)
    end
end
