require 'rails_helper'


RSpec.describe Ipapi do
  describe '#call' do
    it 'returns current location', :vcr do
      json = Ipapi.call

      expect(json).to include("ip")
    end
  end
end
