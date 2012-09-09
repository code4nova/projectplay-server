require 'net/http'
class PlaygroundsController < ApplicationController
  # GET /playgrounds
  # GET /playgrounds.json
  def index
    @playgrounds = Playground.all

    respond_to do |format|
      format.html # index.html.erb
      format.json { render :json => @playgrounds }
    end
  end

  def addToGooglePlaces
    # The API key info is stored in an environmental variable for privacy
    # To add env variables to Heroku, use for ex: heroku config:add GPLACES_KEY=8N029N81
    @playgrounds = Playground.all
    url = "https://maps.googleapis.com/maps/api/place/add/json?sensor=false&key=" + ENV['GPLACES_KEY']
    #@playgrounds.each do |p|
    p = @playgrounds.first
    @playground = p
      # Form the json request according to Google Places API:
      # https://developers.google.com/places/documentation/actions#PlaceReports
      json =  { "location" => { "lat" => p.lat, "lng" => p.long}, "accuracy" => 50, "name" => p.name, "types" => ["park"], "language" => "en" }.to_json
      @returninfo = post(url,json)
      @jsonrequest = json
    #end
    # @returninfo will be available to the view 
    
    respond_to do |format|
      format.html # addToGooglePlaces.html.erb
      format.json { render :json => @playgrounds }
    end
  end
=begin
  def requestgp(req)
    res = Net::HTTP.start('maps.googleapis.com', '443') { |http|http.request(req) }
    unless res.kind_of?(Net::HTTPSuccess)
      handle_error(req, res)
    end
    res
  end
=end
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

  # GET /playgrounds/1
  # GET /playgrounds/1.json
  def show
    @playground = Playground.find(params[:id])

    respond_to do |format|
      format.html # show.html.erb
      format.json { render :json => @playground }
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
