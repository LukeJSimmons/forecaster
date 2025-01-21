require 'rails_helper'

RSpec.describe Location, type: :model do
  it 'has a city' do
    location = Location.new(
      city: '',
      country: 'US'
    )

    expect(location).to_not be_valid

    location = Location.new(
      city: 'Little Rock',
      country: 'US'
    )

    expect(location).to be_valid
  end

  it 'has a unique city' do
    location = Location.new(
      city: 'Little Rock',
      country: 'US'
    )

    location.save

    expect(location).to be_valid

    location2 = Location.new(
      city: 'Little Rock',
      country: 'US'
    )

    expect(location2).to_not be_valid
  end

  it 'has a country' do
    location = Location.new(
      city: 'Little Rock',
      country: ''
    )

    expect(location).to_not be_valid

    location = Location.new(
      city: 'Little Rock',
      country: 'US'
    )

    expect(location).to be_valid
  end
end