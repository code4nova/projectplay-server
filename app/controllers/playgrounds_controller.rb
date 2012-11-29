require 'net/http'
require 'uri'
class PlaygroundsController < ApplicationController
  # GET /playgrounds
  # GET /playgrounds.json
  def index
    @playgrounds = Playground.all
    @playgroundURL = Hash.new
    # For every playground in the database, get a Places Page URL if one exists
    # The best primaryish key I can find is basically the playground name
    # But, because there could be different spellings/variances, we also search
    # against the Aliases relation for each Playground listing
=begin   
    @playgrounds.each do |p|
      # If we don't get a URL from the actual name, then hit the aliases
      url1 = getURLtoGooglePlacePage(p.name)
      if url1 != ""
        puts "Found a URL w/o alias: " + url1
      end
      if url1 == ""
        if p.aliases.count != 0 
          p.aliases.each do |a|
            url2 = getURLtoGooglePlacePage(a.aliasname)
            unless url2.nil?
              puts "Saving an alias URL for: " + p.name
              @playgroundURL[p.name] = url2
            end
          end
        else
          @playgroundURL[p.name] = ""
        end
        unless @playgroundURL.has_key?(p.name)
          @playgroundURL[p.name] = ""
        end
      else
        puts "saving a non-alias URL for: " + p.name
        @playgroundURL[p.name] = url1
      end
    end
=end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @playgrounds, :callback => params[:callback]}
      #format.json { render :json => { :playgrounds => @playgrounds, :playgroundURLs => @playgroundURL }, :callback => params[:callback]}
    end
  end
  
  def getPlacesURLforPlayground
    # Find if there is google places page for raw name
    @urlweb = ""
    @urlweb = getURLtoGooglePlacePage(params[:name])
    if @urlweb == ""
      # Are there aliases?
      playground = Playground.where("name = ?", params[:name]).first
      if playground.nil?
        @urlweb = "Playground Not in ProjectPlay Database"
      else  
        if playground.aliases.count != 0 
          playground.aliases.each do |a|
            url2 = getURLtoGooglePlacePage(a.aliasname)
            unless url2.nil?
              @urlweb = url2
            end
          end
        end
      end
    end
    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => { :url => @urlweb}, :callback => params[:callback]}
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
      radius = ((5280/2)/3.28084).floor
    else
      radius = (params[:radius].to_i/3.28084).floor
    end
    usergeo = get_geo_from_google(params[:address])
    # geocode the address into lat long, and then make the web request to places
    @playgroundset = showFromGooglePlaces(usergeo[:lat], usergeo[:long], radius)
    #@playgroundset = @playgroundhash["playground"]
    #@urlset = @playgroundhash["placespage"]
    # send back result set of playgrounds within that radius from the address - json dataset
    respond_to do |format|
      format.html # getPlaygrounds.html.erb
      format.json { render :json => @playgroundset, :callback => params[:callback]}
    end
  end

  def showFromGooglePlaces(lat, long, radius)
    if radius != 0
      url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=" + lat.to_s + "," +
      long.to_s + "&radius=" + radius.to_s + "&types=park&sensor=false&key=" + ENV['GPLACES_KEY'] 
    else
      url = "https://maps.googleapis.com/maps/api/place/search/json?location=" + lat.to_s + "," +
      long.to_s + "&rankby=distance&types=park&sensor=false&key=" + ENV['GPLACES_KEY'] 
    end
    # Request all playgrounds from Google Places under our API key that are radius from lat,long
    returninfo = postURLonly(url)
    #puts "URL: " + url
    #puts "Return info: " + returninfo.to_s
    jdoc = JSON.parse(returninfo)
    # jdoc is a result - so nested hashes would make googresults a hash
    googresults = jdoc.fetch("results")
    # Googresults is an array - each element should be one listing of Gplaces
    # BUT, the results are paginated - so, we need to see if there are more than 20:
    # compare the results to what is in our database for the id
    playgroundresult = Array.new
    placesurl = ""
    placespage = ""
    placespagehash = Hash.new
    # look against the results at least once
    googresults.each do |r|
      if Playground.where("name = ?", r.fetch("name")).first
        # This is a Playground Place in our database - now check against aliases
        currpg = Playground.where("name = ?", r.fetch("name")).first
        playgroundresult.push(currpg)
      end
    end
    i = 0
    while jdoc.has_key?("next_page_token")
      puts "There is a next page token, looking at next set of results now"
      #url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=" + lat.to_s + "," +
      #long.to_s + "&radius=" + radius.to_s + "&types=park&sensor=false&key=" + ENV['GPLACES_KEY'] +
      #"&pagetoken=" + jdoc.fetch("next_page_token")
      sleep(5)
      url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?pagetoken=" +
        URI.escape(jdoc.fetch("next_page_token").to_s) + "&key=" + ENV['GPLACES_KEY'] + "&location=" + lat.to_s + "," +
        long.to_s + "&radius=" + radius.floor.to_s + "&types=park&sensor=false"
      puts "url: " + url
      returninfo = postURLonly(url)
      jdoc = JSON.parse(returninfo)
      googresults = jdoc.fetch("results")
      puts returninfo.to_s
      googresults.each do |r|
        if Playground.where("name = ?", r.fetch("name")).first
          # This is a Playground Place in our database - now check against aliases
          currpg = Playground.where("name = ?", r.fetch("name")).first
          playgroundresult.push(currpg)
        end
      end
      if jdoc.has_key?("next_page_token")
        puts "Jdoc still has a token, on page no: " + i.to_s
        i = i+1
      end
    end
    # playgroundresult is an array of playground ActiveRecord objects - each one
    # being a playground in the rails database
    # make a hash of our arrays and return it
    #returnhash = Hash.new
    #returnhash = {"dbplaygrounds" => playgroundresult, "googplaygrounds" => googresultsfound }
    return playgroundresult
  end
  
  def getURLtoGooglePlacePage(name)
    # Pass in a string of the park name, and get back a URL if there is a page,
    # if not, get back a nil
    # This is a multi-step process (according to the API docs):
    # Step 1: Find the Google Places Search result
    # Step 2: Get the reference key from it for the result you want
    # Step 3: Do a Detailed search query, get the URL if one exists
    url = "https://maps.googleapis.com/maps/api/place/nearbysearch/json?location=38.818860,-77.091497&radius=10000" + 
    "&sensor=false&key=" + ENV['GPLACES_KEY'] + "&name=" + URI.escape(name)
    placesurlbase = "https://maps.googleapis.com/maps/api/place/details/json?sensor=false&key=" +
      ENV['GPLACES_KEY'] + "&reference="
    url3 = ""
    returninfo = postURLonly(url)
    jdoc = JSON.parse(returninfo)
    googresults = jdoc.fetch("results")
    #puts "url: " + url
    # are there even GPlaces results?
    googresults.each do |r|
      #puts "Fetch name is: " + r.fetch("name") + " Our DB name: " + name
      next if r.fetch("name") != name
      placesurl = placesurlbase +  r.fetch("reference")
      #puts "Placesurl: " + placesurl
      placesinfo = postURLonly(placesurl)
      kdoc = JSON.parse(placesinfo)
      placesresults = kdoc.fetch("result")
      if placesresults.has_key?("url")
        #puts "Found a url!! Returning: " + placesresults.fetch("url")
        url3 = placesresults.fetch("url")
        return url3
      end
    end
    return ""
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
