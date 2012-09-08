# This file is auto-generated from the current state of the database. Instead
# of editing this file, please use the migrations feature of Active Record to
# incrementally modify your database, and then regenerate this schema definition.
#
# Note that this schema.rb definition is the authoritative source for your
# database schema. If you need to create the application database on another
# system, you should be using db:schema:load, not running all the migrations
# from scratch. The latter is a flawed and unsustainable approach (the more migrations
# you'll amass, the slower it'll run and the greater likelihood for issues).
#
# It's strongly recommended to check this file into your version control system.

ActiveRecord::Schema.define(:version => 20120908185222) do

  create_table "playgrounds", :force => true do |t|
    t.string   "name"
    t.integer  "mapid"
    t.string   "agelevel"
    t.integer  "totplay"
    t.integer  "openaccess"
    t.integer  "invitation"
    t.integer  "access"
    t.integer  "safelocation"
    t.integer  "conditions"
    t.integer  "monitoring"
    t.integer  "programming"
    t.integer  "weather"
    t.integer  "seating"
    t.integer  "restrooms"
    t.integer  "drinkingw"
    t.integer  "physicald"
    t.integer  "socialdom"
    t.integer  "intellect"
    t.integer  "naturualen"
    t.integer  "freeunstruct"
    t.text     "specificcomments"
    t.text     "generalcomments"
    t.integer  "compsum"
    t.integer  "modsum"
    t.integer  "graspvalue"
    t.string   "class"
    t.text     "subarea"
    t.datetime "created_at",       :null => false
    t.datetime "updated_at",       :null => false
  end

end
