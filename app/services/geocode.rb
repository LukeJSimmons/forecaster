require "uri"
require "net/http"

class Geocode < ApplicationService
  attr_reader :location

  def initialize(location)
    @location = location
  end

  def call
    uri = URI("https://geocode.xyz")

    uri_params = {
        "auth" => "205947941065469632418x93807 ",
        "locate" => "#{@location.city},#{@location.region},#{@location.country}",
        "geoit" => "json"
    }

    uri.query = URI.encode_www_form(uri_params)

    response = Net::HTTP.get(uri)
    json = JSON.parse(response)

    if json["error"]
      uri_params["locate"] = "#{@location.city},#{@location.country}"
      uri.query = URI.encode_www_form(uri_params)
      response = Net::HTTP.get(uri)
      json = JSON.parse(response)
    end

    json
  end
end
