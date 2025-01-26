require 'json'
require 'net/http'

class Ipapi < ApplicationService
  def call
    loc = Net::HTTP.get(URI("https://ipapi.co/json/"))
    JSON.parse(loc)
  end
end