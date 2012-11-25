require 'net/http'
class PlaygroundsController < ApplicationController
  # GET /playgrounds
  # GET /playgrounds.json
  def index
    @playgrounds = Playground.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @playgrounds, :callback => params[:callback]}
    end
  end
  
  def showpage
    @playgrounds = Playground.page(params[:page]).per(params[:numperpage])

    respond_to do |format|
      format.html # showpage.html.erb
      format.json { render :json => @playgrounds, :callback => params[:callback]}
    end
  end
  
  def getPlaygrounds
    # from params[:address] params[:radius in feet]
    radius = 0
    if params[:radius].nil?
      # places API takes radius in meters - there are 3.28084 feet per meter
      radius = (5280/2)/3.28084
    else
      radius = params[:radius].to_i/3.28084
    end
    usergeo = get_geo_from_google(params[:address])
    # geocode the address into lat long, and then make the web request to places
    @playgroundhash = showFromGooglePlaces(usergeo[:lat], usergeo[:long], radius)
    #@playgroundset = @playgroundhash["playground"]
    #@urlset = @playgroundhash["placespage"]
    # send back result set of playgrounds within that radius from the address - json dataset
    respond_to do |format|
      format.html # getPlaygrounds.html.erb
      format.json { render :json => @playgroundhash, :callback => params[:callback]}
    end
  end

  def showFromGooglePlaces(lat, long, radius)
    if radius != 0
      url = "https://maps.googleapis.com/maps/api/place/search/json?location=" + lat.to_s + "," + long.to_s + "&radius=" + radius.to_s + "&types=park&sensor=false&key=" + ENV['GPLACES_KEY'] 
    else
      url = "https://maps.googleapis.com/maps/api/place/search/json?location=" + lat.to_s + "," + long.to_s + "&rankby=distance&types=park&sensor=false&key=" + ENV['GPLACES_KEY'] 
    end
    # Request all playgrounds from Google Places under our API key that are radius from lat,long
    returninfo = postURLonly(url)
    #puts "URL: " + url
    #puts "Return info: " + returninfo.to_s
    jdoc = JSON.parse(returninfo)
    # jdoc is a result - so nested hashes would make googresults a hash
    googresults = jdoc.fetch("results")
    # Googresults is an array - each element should be one listing of Gplaces
    # compare the results to what is in our database for the id
    playgroundresult = Array.new
    placesurl = ""
    placespage = ""
    placespagehash = Hash.new
    googresults.each do |r|
      # check if there is a Google Places URL for whatever this place is:
      placesurl = "https://maps.googleapis.com/maps/api/place/details/json?reference=" +
      r.fetch("reference") + "&sensor=true&key=" + ENV['GPLACES_KEY']
      placesinfo = postURLonly(placesurl)
      kdoc = JSON.parse(placesinfo)
      #puts "Google Places Detail: " + kdoc.fetch("result").to_s
      placesresults = kdoc.fetch("result")
      if placesresults.has_key?("url")
        placespagehash[r.fetch("name")] = placesresults.fetch("url")
        puts "Found a URL! Name:" + r.fetch("name") + " URL: " + placesresults.fetch("url")
      end
    end
    googresults.each do |r|
      if Playground.where("name = ?", r.fetch("name")).first
        # This is a Playground Place in our database - now check against aliases
        currpg = Playground.where("name = ?", r.fetch("name")).first
        placespage = ""
        if placespagehash.has_key?(r.fetch("name"))
           placespage = placespagehash[r.fetch("name")]
        else
          aliases = Alias.where("playground_id = ?", currpg.id)
          aliases.each do |a|
            if placespagehash.has_key?(a.aliasname)
              placespage = placespagehash[a.aliasname]
              puts "Found a match url: " + placespage
            end
          end
        end
        # Check that this playgroundresult isn't already in the array
        unless playgroundresult.include?({ "playground" => Playground.where("name = ?", r.fetch("name")).first, "placespage" => placespage})
        # The array is an array of hashes, first key is the Playground ActiveRecord object, second key
        # is the URL returned from a Google Places Details query which should be the URL
        # of the special Google Places page just for that park with all kinds of neat
        # G+ user contributed content
          playgroundresult.push({ "playground" => Playground.where("name = ?", r.fetch("name")).first, "placespage" => placespage})
        end
      end
    end
    # playgroundresult is an array of playground ActiveRecord objects - each one
    # being a playground in the rails database
    # make a hash of our arrays and return it
    #returnhash = Hash.new
    #returnhash = {"dbplaygrounds" => playgroundresult, "googplaygrounds" => googresultsfound }
    return playgroundresult
  end

  def addToGooglePlaces
    # The API key info is stored in an environmental variable for privacy
    # To add env variables to Heroku, use for ex: heroku config:add GPLACES_KEY=8N029N81
    @playgrounds = Playground.all
    
    url = "https://maps.googleapis.com/maps/api/place/add/json?sensor=false&key=" + ENV['GPLACES_KEY']
    @playgrounds.each do |p|
    #p = @playgrounds.first
    # Check and see first if this playground doesn't already exist:
    #url = "https://maps.googleapis.com/maps/api/place/search/json?location=" + p.lat + "," + p.long + "&radius=1&types=park&sensor=false&key=" + ENV['GPLACES_KEY']
    #@returninfo = postURLonly(url)
    #jdoc2 = JSON.parse(@returninfo)
    #googresults = jdoc2.fetch("results")
      @playground = p
      # Form the json request according to Google Places API:
      # https://developers.google.com/places/documentation/actions#PlaceReports
      if p.google_placesid.nil?
        json =  { "location" => { "lat" => p.lat, "lng" => p.long}, "accuracy" => 50, "name" => p.name, "types" => ["park"], "language" => "en" }.to_json
        @returninfo = post(url,json)
        @jsonrequest = json
        jdoc = JSON.parse(@returninfo)
        puts "id is: " + jdoc.fetch("id")
        p.google_placesid = jdoc.fetch("id")
        p.save
      end
    end
    # @returninfo will be available to the view 
    
    respond_to do |format|
      format.html # addToGooglePlaces.html.erb
      format.json { render :json => @playgrounds }
    end
  end

  def post(uri, json)
    # this sequence of code must be done for HTTP/SSL/Basic Auth b/c use_ssl must be specified before starting session
    res = ""
    http = Net::HTTP.new('maps.googleapis.com', '443')
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    resp = http.start do |ht|  
      req = Net::HTTP::Post.new(uri)
      req["content-type"] = "application/json"
      req.body = json
      res = ht.request(req)
    end
    puts res.body
    res.body
  end

  def postURLonly(uri)
    http = Net::HTTP.new('maps.googleapis.com', '443')
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    resp = http.start do |ht|  
      req = Net::HTTP::Get.new(uri)
      res = ht.request(req)
      return res.body
    end
  end
  
  def get_geo_from_google(address)
    geocoder = "http://maps.googleapis.com/maps/api/geocode/json?address="
    output = "&sensor=false"
    # address = "424+ellis+st+san+francisco"
    # replace any ampersands with "and" since ampersands don't seem to work with the google query
    address =  address.sub( "&", "and" )
    request = geocoder + address.tr(' ', '+') + output
    url = URI.escape(request)
    resp = Net::HTTP.get_response(URI.parse(url))
    #parse result if result received properly
    if resp.is_a?(Net::HTTPSuccess)
      #parse the json
      parse = JSON.parse(resp.body)
      #check if google went well
      if parse.fetch("status") == "OK"
       # return parse if raw == true
        parse.fetch("results").each do |result|
          geo_hash = {  :lat => result["geometry"]["location"]["lat"],
                        :long => result["geometry"]["location"]["lng"]
          }
          return geo_hash
        end
     end
    end
    return parse 
  end
  
  
  # GET /playgrounds/1
  # GET /playgrounds/1.json
  def show
    @playground = Playground.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @playground, :callback => params[:callback] }
    end
  end

  # GET /playgrounds/new
  # GET /playgrounds/new.json
  def new
    @playground = Playground.new

    respond_to do |format|
      format.html # new.html.erb
      format.json { render :json => @playground }
    end
  end

  # GET /playgrounds/1/edit
  def edit
    @playground = Playground.find(params[:id])
  end

  # POST /playgrounds
  # POST /playgrounds.json
  def create
    @playground = Playground.new(params[:playground])

    respond_to do |format|
      if @playground.save
        format.html { redirect_to @playground, :notice => 'Playground was successfully created.' }
        format.json { render :json => @playground, :status => :created, :location => @playground }
      else
        format.html { render :action => "new" }
        format.json { render :json => @playground.errors, :status => :unprocessable_entity }
      end
    end
  end

  # PUT /playgrounds/1
  # PUT /playgrounds/1.json
  def update
    @playground = Playground.find(params[:id])

    respond_to do |format|
      if @playground.update_attributes(params[:playground])
        format.html { redirect_to @playground, :notice => 'Playground was successfully updated.' }
        format.json { head :no_content }
      else
        format.html { render :action => "edit" }
        format.json { render :json => @playground.errors, :status => :unprocessable_entity }
      end
    end
  end

  # DELETE /playgrounds/1
  # DELETE /playgrounds/1.json
  def destroy
    @playground = Playground.find(params[:id])
    @playground.destroy

    respond_to do |format|
      format.html { redirect_to playgrounds_url }
      format.json { head :no_content }
    end
  end
end
