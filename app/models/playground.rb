class Playground < ActiveRecord::Base
  require 'cgi'
  acts_as_mappable :lng_column_name => :lon
  attr_accessible :access, :agelevel, :playclass, :compsum, :conditions,
  :drinkingw, :freeunstruct, :generalcomments, :graspvalue, :intellect,
  :invitation, :mapid, :modsum, :monitoring, :name, :naturualen,
  :openaccess, :physicald, :programming, :restrooms, :safelocation, :seating,
  :socialdom, :specificcomments, :subarea, :totplay, :weather, :lat, :long, :google_placesid
  
  has_many :aliases

  def distancefromorigin(orig)
        #passed the origin array from the playgrounds controller
        lat1 = orig[0]
        long1 = orig[1]
        lat2 = self.lat
        long2 = self.lon
        radiansperdegree = 3.14159265359 / 180	 
        lonsrad = (long2 - long1) * radiansperdegree
        latsrad = (lat2 - lat1) * radiansperdegree	 
        lat1rad = lat1 * radiansperdegree	 
        lat2rad = lat2 * radiansperdegree 	 
        a = (Math.sin(latsrad/2))**2 + Math.cos(lat1rad) * Math.cos(lat2rad) * (Math.sin(lonsrad/2))**2
        c = 2 * Math.atan2( Math.sqrt(a), Math.sqrt(1-a))
        # assuming the great circle radius is 6371 km = abt 3958 miles
        dist = 3958 * c
        # list feet if under 1 mile. And miles to 2 decimal places if over 1 mile
        if dist < 1
            dist = dist * 5280
            disthash = { :dist => dist.round.to_i, :unit => "ft" }
        else
            disthash = { :dist => dist.round(2), :unit => "mi" }
        end
        
        return disthash
    end

end
