class RemoveUserIdFromLocations < ActiveRecord::Migration[8.0]
  def change
    remove_reference :locations, :user, null: false, foreign_key: true
  end
end
