class AddChartUrlToLocation < ActiveRecord::Migration[8.0]
  def change
    add_column :locations, :chart_url, :string
  end
end
