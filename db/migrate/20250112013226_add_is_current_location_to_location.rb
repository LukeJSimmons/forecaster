class AddIsCurrentLocationToLocation < ActiveRecord::Migration[8.0]
  def change
    add_column :locations, :is_current_location, :boolean
  end
end
