class AddGoogleIdToPlaygrounds < ActiveRecord::Migration
  def change
    add_column :playgrounds, :google_places_id, :string
  end
end
