class Playground < ActiveRecord::Base
  require 'cgi'
  acts_as_mappable :lng_column_name => :long
  attr_accessible :access, :agelevel, :playclass, :compsum, :conditions,
  :drinkingw, :freeunstruct, :generalcomments, :graspvalue, :intellect,
  :invitation, :mapid, :modsum, :monitoring, :name, :naturualen,
  :openaccess, :physicald, :programming, :restrooms, :safelocation, :seating,
  :socialdom, :specificcomments, :subarea, :totplay, :weather, :lat, :long, :google_placesid
  
  has_many :aliases

  scope :near, lambda{ |*args|
                        origin = *args.first[:origin]
                        if (origin).is_a?(Array)
                          origin_lat, origin_lng = origin
                        else
                          origin_lat, origin_lng = origin.lat, origin.lng
                        end
                        origin_lat, origin_lng = deg2rad(origin_lat), deg2rad(origin_lng)
                        within = *args.first[:within]
                        {
                          :conditions => %(
                            (ACOS(COS(#{origin_lat})*COS(#{origin_lng})*COS(RADIANS(playgrounds.lat))*COS(RADIANS(playgrounds.long))+
                            COS(#{origin_lat})*SIN(#{origin_lng})*COS(RADIANS(playgrounds.lat))*SIN(RADIANS(playgrounds.long))+
                            SIN(#{origin_lat})*SIN(RADIANS(playgrounds.lat)))*3963) <= #{within}
                          ),
                          :select => %( playgrounds.*,
                            (ACOS(COS(#{origin_lat})*COS(#{origin_lng})*COS(RADIANS(playgrounds.lat))*COS(RADIANS(playgrounds.long))+
                            COS(#{origin_lat})*SIN(#{origin_lng})*COS(RADIANS(playgrounds.lat))*SIN(RADIANS(playgrounds.long))+
                            SIN(#{origin_lat})*SIN(RADIANS(playgrounds.lat)))*3963) AS distance
                          )
                        }
                      }

  def distancefromorigin(orig)
        #passed the origin array from the playgrounds controller
        lat1 = orig[0]
        long1 = orig[1]
        lat2 = self.lat
        long2 = self.long
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
