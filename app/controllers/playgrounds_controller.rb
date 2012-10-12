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
    # geocode the address into lat long, and then make the web request to places
    # send back result set of playgrounds within that radius from the address - json dataset
  end

  def showFromGooglePlaces
    url = "https://maps.googleapis.com/maps/api/place/search/json?location=38.8162,-77.0713&radius=5000&types=park&sensor=false&key=" + ENV['GPLACES_KEY']
    # Request all playgrounds from Google Places under our API key that are 50,000 meters (max radius) from oldtown Alexandria (lat,long) = 38.8162, 77.0713
    @returninfo = postURLonly(url)

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
    res.body
  end

  def postURLonly(uri)
    res = ""
    http = Net::HTTP.new('maps.googleapis.com', '443')
    http.use_ssl = true
    http.verify_mode = OpenSSL::SSL::VERIFY_NONE
    resp = http.start do |ht|  
      req = Net::HTTP::Post.new(uri)
      #req["content-type"] = "application/json"
      res = ht.request(req)
    end
    res.body
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
