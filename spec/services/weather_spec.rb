require 'rails_helper'


RSpec.describe Weather do
  describe '#call' do
    it 'generates 7 forecasts for location', :vcr do
      location = Location.new(city: 'Little Rock', country: 'United States', latitude: 34.72661, longitude: -92.37521, id: 1)

      Weather.call(location)

      expect(location.forecasts.length).to eq(7)
    end

    it 'generates 7 forecasts with max and min temps', :vcr do
      location = Location.new(city: 'Little Rock', country: 'United States', latitude: 34.72661, longitude: -92.37521, id: 1)

      Weather.call(location)

      max_temps = location.forecasts.map { |forecast| forecast.max_temp }
      min_temps = location.forecasts.map { |forecast| forecast.min_temp }

      expect(max_temps.length).to eq(7)
      expect(min_temps.length).to eq(7)
    end

    it 'generates 7 forecasts with dates', :vcr do
      location = Location.new(city: 'Little Rock', country: 'United States', latitude: 34.72661, longitude: -92.37521, id: 1)

      Weather.call(location)

      dates = location.forecasts.map { |forecast| forecast.date }

      expect(dates.length).to eq(7)
    end
  end
end
