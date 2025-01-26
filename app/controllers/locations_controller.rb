
class LocationsController < ApplicationController
  def new
    @location = Location.new
  end

  def create
    @location = Location.new(location_params)

    coordinates = GeoCode.call(@location)

    @location.longitude = coordinates["longt"]
    @location.latitude = coordinates["latt"]

    if @location.save
      Weather.call(@location)
      @location.chart_url = ImageCharts.call(@location.forecasts)
      @location.save

      redirect_to @location
    else
      render :new, status: :unprocessable_entity
    end
  end

  def show
    @location = Location.find(params[:id])

    if @location.is_current_location
      current_location = IPAPI.call
      @location.update(city: current_location["city"], region: current_location["region"], country: current_location["country"])
      coordinates = GeoCode.call(@location)

      @location.longitude = coordinates["longt"]
      @location.latitude = coordinates["latt"]
    end

    Weather.call(@location)
    @location.chart_url = ImageCharts.call(@location.forecasts)

    @location.save
  end

  def index
    current_location = IPAPI.call
    current_location_model = Location.all.find_or_initialize_by(is_current_location: true)

    current_location_model.update(city: current_location["city"], region: current_location["region"], country: current_location["country"])

    @locations = Location.all
  end

  def destroy
    @location = Location.find(params[:id])
    @location.destroy

    redirect_to locations_path
  end

  def edit
    @location = Location.find(params[:id])
  end

  def update
    @location = Location.find(params[:id])

    if @location.update(location_params)
      redirect_to @location
    else
      render :edit, status: :unprocessable_entity
    end
  end

  private

    def location_params
      params.require(:location).permit(:city, :region, :country, :latitude, :longitude, :chart_url)
    end
end
