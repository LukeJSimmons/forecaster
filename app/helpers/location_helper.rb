module LocationHelper
  def parse_location(location)
    uri = URI("https://geocode.xyz")

    uri_params = {
        "auth" => "205947941065469632418x93807 ",
        "locate" => "#{location.city} #{location.region} #{location.country}",
        "geoit" => "json"
    }

    uri.query = URI.encode_www_form(uri_params)

    response = Net::HTTP.get(uri)
    JSON.parse(response)
  end

  def get_current_location
    loc = Net::HTTP.get(URI("https://ipapi.co/json/"))
    JSON.parse(loc)
  end

  def get_weather(lat, long)
    weather = Net::HTTP.get(URI("https://api.open-meteo.com/v1/forecast?latitude=#{lat}&longitude=#{long}&daily=temperature_2m_max,temperature_2m_min&temperature_unit=fahrenheit"))
    JSON.parse(weather)
  end

  def generate_forecasts(location)
    weather = get_weather(location.latitude, location.longitude)

    weather["daily"]["time"].each_with_index do |date, index|
      forecast = location.forecasts.find_or_initialize_by(date: date)
      forecast.max_temp = weather["daily"]["temperature_2m_max"][index]
      forecast.min_temp = weather["daily"]["temperature_2m_min"][index]
      forecast.save!
    end
  end


  def generate_chart_url(location)
    dates = location.forecasts.map { |forecast| forecast.date.strftime("%A") }
    min_temps = location.forecasts.map { |forecast| forecast.min_temp }
    max_temps = location.forecasts.map { |forecast| forecast.max_temp }

    "https://image-charts.com/chart?cht=lc&chd=t:#{max_temps.join(',')}|#{min_temps.join(',')}&chl=#{max_temps.join('|')}|#{min_temps.join('|')}&chlps=align,50&chs=700x350&chxt=x,y&chxl=0:|#{dates.join('|')}&chdl=High|Low&chdlp=t&chco=a51d2a,0250c4"
  end
end
