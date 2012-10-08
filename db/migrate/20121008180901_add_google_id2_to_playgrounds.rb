class AddGoogleId2ToPlaygrounds < ActiveRecord::Migration
  def change
    add_column :playgrounds, :google_placesid, :string
  end
end
