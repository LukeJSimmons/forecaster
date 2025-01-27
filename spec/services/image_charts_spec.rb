require 'rails_helper'


RSpec.describe ImageCharts do
  describe '#call' do
    it 'returns valid url', :vcr do
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

      chart_url = ImageCharts.call(location.forecasts)

      expect(chart_url).to eq('https://image-charts.com/chart?cht=lc&chd=a:40.8,49.8,45.2,55.1,54.8,54.3,45.1|29.4,31.2,30.1,33.8,37.9,46.0,29.4&chl=40.8|49.8|45.2|55.1|54.8|54.3|45.1|29.4|31.2|30.1|33.8|37.9|46.0|29.4&chlps=align,50&chs=700x350&chxt=x,y&chxl=0:|Monday|Tuesday|Wednesday|Thursday|Friday|Saturday|Sunday&chdl=High|Low&chdlp=t&chco=a51d2a,0250c4')
    end
  end
end
