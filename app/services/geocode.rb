class GeoCode < ApplicationService
  attr_reader :location

  def initialize(location)
    @location = location
  end

  def call
    uri = URI("https://geocode.xyz")

    uri_params = {
        "auth" => "205947941065469632418x93807 ",
        "locate" => "#{@location.city} #{@location.country}",
        "geoit" => "json"
    }

    uri.query = URI.encode_www_form(uri_params)

    response = Net::HTTP.get(uri)
    JSON.parse(response)
  end
end