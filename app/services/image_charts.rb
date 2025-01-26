class ImageCharts < ApplicationService
  def initialize(forecasts)
    @forecasts = forecasts
  end

  def call
    dates = @forecasts.map { |forecast| forecast.date.strftime("%A") }
    min_temps = @forecasts.map { |forecast| forecast.min_temp }
    max_temps = @forecasts.map { |forecast| forecast.max_temp }

    "https://image-charts.com/chart?cht=lc&chd=t:#{max_temps.join(',')}|#{min_temps.join(',')}&chl=#{max_temps.join('|')}|#{min_temps.join('|')}&chlps=align,50&chs=700x350&chxt=x,y&chxl=0:|#{dates.join('|')}&chdl=High|Low&chdlp=t&chco=a51d2a,0250c4"
  end
end