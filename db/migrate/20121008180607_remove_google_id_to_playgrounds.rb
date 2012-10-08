class RemoveGoogleIdToPlaygrounds < ActiveRecord::Migration
  def up
    remove_column :playgrounds, :google_places_id
  end

  def down
    add_column :playgrounds, :google_places_id, :string
  end
end
