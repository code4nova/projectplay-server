class RemapPlaygroundFields < ActiveRecord::Migration
  def up
    change_table :playgrounds do |t|
      t.rename :openaccess, :opentopublic
      t.rename :access, :howtogetthere
      t.rename :conditions, :shade
      t.rename :physicald, :activeplay
      t.rename :socialdom, :socialplay
      t.rename :intellect, :creativeplay
      t.rename :freeunstruct, :freeplay
    end
  end

  def down
    t.rename :opentopublic, :openaccess
    t.rename :howtogetthere, :access 
    t.rename :shade, :conditions 
    t.rename :activeplay, :physicald
    t.rename :socialplay, :socialdom 
    t.rename :creativeplay, :intellect 
    t.rename :freeplay, :freeunstruct 
  end
end
