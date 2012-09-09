# This file should contain all the record creation needed to seed the database with its default values.
# The data can then be loaded with the rake db:seed (or created alongside the db with db:setup).
#
# Examples:
#
#   cities = City.create([{ :name => 'Chicago' }, { :name => 'Copenhagen' }])
#   Mayor.create(:name => 'Daley', :city => cities.first)
require 'spreadsheet'
require 'csv'

  #first delete out all the current table data
  Playground.delete_all
=begin
  # Now import the spreadsheet and populate the Playgrounds table with the imported data -the below code can be
  # uncommented in development to seed in an Excel spreadsheet, but this doesn't
  # Work on Heroku (must use CSV there)
  puts Rails.root.to_s + '/db/Alex_Components.xls'
  book = Spreadsheet.open(Rails.root.to_s + '/db/Alex_Components.xls')
  sheet1 = book.worksheet('scores') # can use an index or worksheet name
  CSV.open(Rails.root.to_s + '/db/Alex_Components.csv', "wb") do |csv|
  sheet1.each do |row|
    # skip if its the first row
    unless row[0] == 'LOCATION'
      
      # first check and see if record exists
      unless row.nil?
        Playground.create(:name => row[0], :mapid => row[1], :agelevel => row[2], :totplay => row[3], :openaccess => row[4], :invitation => row[5], :access => row[6],
                          :safelocation => row[7], :conditions => row[8], :monitoring => row[9], :programming => row[10], :weather => row[11], :seating => row[12],
                          :restrooms => row[13], :drinkingw => row[14],  :physicald => row[15], :socialdom => row[16], :intellect => row[17], :naturualen => row[18],
                          :freeunstruct => row[19], :specificcomments => row[20], :generalcomments => row[21], :compsum => row[22], :modsum => row[23],
                          :graspvalue => row[24], :playclass => row[25], :subarea => row[26], :lat => row[27], :long => row[28])
      
      end
    end
    name = row[0] 
  csv << [name, row[1], row[2], row[3].to_i, row[4].to_i, row[5].to_i, row[6].to_i, row[7].to_i, row[8].to_i,
          row[9].to_i, row[10].to_i, row[11].to_i, row[12].to_i, row[13].to_i, row[14].to_i, row[15].to_i, row[16].to_i, row[17].to_i,
          row[18].to_i, row[19].to_i, row[20], row[21], row[22].to_i, row[23].to_i, row[24].to_i, row[25], row[26],
          row[27], row[28]]
  end
  end
=end
#=begin
  #Playground.delete_all
  # To import for production:
  i = 0
  CSV.foreach(Rails.root.to_s + '/db/Alex_Components.csv') do |row|
    unless row[0] == 'LOCATION'
      puts "Writing name of: " + row[0].to_s
      i = i + 1
      Playground.create(:name => row[0], :mapid => row[1], :agelevel => row[2], :totplay => row[3], :openaccess => row[4], :invitation => row[5], :access => row[6],
                        :safelocation => row[7], :conditions => row[8], :monitoring => row[9], :programming => row[10], :weather => row[11], :seating => row[12],
                        :restrooms => row[13], :drinkingw => row[14],  :physicald => row[15], :socialdom => row[16], :intellect => row[17], :naturualen => row[18],
                        :freeunstruct => row[19], :specificcomments => row[20], :generalcomments => row[21], :compsum => row[22], :modsum => row[23],
                        :graspvalue => row[24], :playclass => row[25], :subarea => row[26], :lat => row[27], :long => row[28])
    end
  end
#=end