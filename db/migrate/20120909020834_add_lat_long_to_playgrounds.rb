class AddLatLongToPlaygrounds < ActiveRecord::Migration
  def change
    add_column :playgrounds, :lat, :float
    add_column :playgrounds, :long, :float
  end
end
