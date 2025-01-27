require 'rails_helper'


RSpec.describe Geocode do
  describe '#call' do
    it 'returns JSON with latitude and longitude', :vcr do
      location = Location.new(city: 'Little Rock', country: 'United States')

      json = Geocode.call(location)

      expect(json["latt"]).to eq("34.72661")
      expect(json["longt"]).to eq("-92.37521")
    end
  end
end
