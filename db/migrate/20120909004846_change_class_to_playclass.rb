class ChangeClassToPlayclass < ActiveRecord::Migration
  def change
	change_table :playgrounds do |t|
		t.rename :class, :playclass
	end
  end

end
