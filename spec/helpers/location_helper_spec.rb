require 'rails_helper'
include LocationHelper

# Specs in this file have access to a helper object that includes
# the LocationHelper. For example:
#
# describe LocationHelper do
#   describe "string concat" do
#     it "concats two strings with spaces" do
#       expect(helper.concat_strings("this","that")).to eq("this that")
#     end
#   end
# end
RSpec.describe LocationHelper, type: :helper do
  describe '#parse_location' do
    it 'returns JSON with latitude and longitude' do
      location = Location.new(city: 'Little Rock', country: 'United States')

      json = parse_location(location)

      expect(json["latt"]).to eq("34.72661")
      expect(json["longt"]).to eq("-92.37521")
    end
  end

  describe '#get_current_location' do
    it 'returns current location' do
      json = get_current_location

      expect(json["ip"]).to be_a(String)
    end
  end

  describe '#get_weather' do
    it 'returns max and min temp for the next 7 days' do
      lat = 34.72661
      long = -92.37521
      weather = get_weather(lat, long)

      expect(weather["daily"]["temperature_2m_max"].length).to eq(7)
      expect(weather["daily"]["temperature_2m_min"].length).to eq(7)
    end

    it 'returns dates for the next 7 days' do
      lat = 34.72661
      long = -92.37521
      weather = get_weather(lat, long)

      expect(weather["daily"]["time"].length).to eq(7)
    end
  end

  describe '#generate_forecasts' do
    it 'generates 7 forecasts for location' do
      location = Location.new(city: 'Little Rock', country: 'United States', latitude: 34.72661, longitude: -92.37521, id: 1)

      generate_forecasts(location)

      expect(location.forecasts.length).to eq(7)
    end

    it 'generates 7 forecasts with max and min temps' do
      location = Location.new(city: 'Little Rock', country: 'United States', latitude: 34.72661, longitude: -92.37521, id: 1)

      generate_forecasts(location)

      max_temps = location.forecasts.map { |forecast| forecast.max_temp }
      min_temps = location.forecasts.map { |forecast| forecast.min_temp }

      expect(max_temps.length).to eq(7)
      expect(min_temps.length).to eq(7)
    end

    it 'generates 7 forecasts with dates' do
      location = Location.new(city: 'Little Rock', country: 'United States', latitude: 34.72661, longitude: -92.37521, id: 1)

      generate_forecasts(location)

      dates = location.forecasts.map { |forecast| forecast.date }

      expect(dates.length).to eq(7)
    end
  end

  describe '#generate_chart_url' do
    it 'returns valid url' do
      location = Location.new(city: 'Little Rock', country: 'United States', latitude: 34.72661, longitude: -92.37521)

      weather = {
        time: [
          "2025-01-13",
          "2025-01-14",
          "2025-01-15",
          "2025-01-16",
          "2025-01-17",
          "2025-01-18",
          "2025-01-19"
        ],
        temperature_2m_max: [ 40.8, 49.8, 45.2, 55.1, 54.8, 54.3, 45.1 ],
        temperature_2m_min: [ 29.4, 31.2, 30.1, 33.8, 37.9, 46, 29.4 ]
      }

      weather[:time].each_with_index do |date, index|
        forecast = location.forecasts.find_or_initialize_by(date: date)
        forecast.max_temp = weather[:temperature_2m_max][index]
        forecast.min_temp = weather[:temperature_2m_min][index]
        forecast.save!
      end

      chart_url = generate_chart_url(location)

      expect(chart_url).to eq('https://image-charts.com/chart?cht=lc&chd=t:40.8,49.8,45.2,55.1,54.8,54.3,45.1|29.4,31.2,30.1,33.8,37.9,46.0,29.4&chl=40.8|49.8|45.2|55.1|54.8|54.3|45.1|29.4|31.2|30.1|33.8|37.9|46.0|29.4&chlps=align,50&chs=700x350&chxt=x,y&chxl=0:|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday&chdl=High|Low&chdlp=t&chco=a51d2a,0250c4')
    end
  end
end
