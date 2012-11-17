class CreateTableCriteriakeys < ActiveRecord::Migration
  def up
    create_table :criteriakeys do |t|
      t.string :criterianame
      t.integer :scalevalue
      t.text :textvalue
    end
  end

  def down
    drop_table :criteriakeys
  end
end
