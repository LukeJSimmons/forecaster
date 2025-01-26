class IPAPI < ApplicationService
  def call
    loc = Net::HTTP.get(URI("https://ipapi.co/json/"))
    JSON.parse(loc)
  end
end