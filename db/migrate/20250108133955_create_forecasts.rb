class CreateForecasts < ActiveRecord::Migration[8.0]
  def change
    create_table :forecasts do |t|
      t.date :date
      t.float :min_temp
      t.float :max_temp
      t.references :location, null: false, foreign_key: true

      t.timestamps
    end
  end
end
