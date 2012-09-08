class CreatePlaygrounds < ActiveRecord::Migration
  def change
    create_table :playgrounds do |t|
      t.string :name
      t.integer :mapid
      t.string :agelevel
      t.integer :totplay
      t.integer :openaccess
      t.integer :invitation
      t.integer :access
      t.integer :safelocation
      t.integer :conditions
      t.integer :monitoring
      t.integer :programming
      t.integer :weather
      t.integer :seating
      t.integer :restrooms
      t.integer :drinkingw
      t.integer :physicald
      t.integer :socialdom
      t.integer :intellect
      t.integer :naturualen
      t.integer :freeunstruct
      t.text :specificcomments
      t.text :generalcomments
      t.integer :compsum
      t.integer :modsum
      t.integer :graspvalue
      t.string :class
      t.text :subarea

      t.timestamps
    end
  end
end
