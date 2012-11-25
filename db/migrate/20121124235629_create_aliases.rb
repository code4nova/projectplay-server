class CreateAliases < ActiveRecord::Migration
  def change
    create_table :aliases do |t|
      t.integer :playground_id
      t.string :aliasname

      t.timestamps
    end
  end
end
