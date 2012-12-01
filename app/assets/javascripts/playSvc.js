var playSvc = function(url) {
	var inst = {};
	inst.baseUrl = url;

	inst.getAllPlaygrounds = function(callback) {
		var getAllUrl = inst.baseUrl + "playgrounds.json" + "?callback=?";
		var caller = callback;
		$.ajax({
		   type: 'GET',
		    url: getAllUrl,
		    async: false,
			contentType: 'application/json',
			dataType: 'jsonp',
		    success: function(json) {
				caller.apply(null, [json]);
		    },
		    error: function(e) {
		       caller.apply(null, [false]);
		    }
		});
	};

	inst.geoCodeAddress = function(address, callback) {
		var caller = callback;

		var geocoder = new google.maps.Geocoder(); 
		geocoder.geocode(
		    { address : address, 
		      region: 'no' 
		    }, 
		    function(results, status){
		      caller.apply(null, [results[0]]);
			}
		);
	};

	inst.getPlaceUrl = function(name, callback) {
		var caller =  callback;

		var getPlaceUrl = inst.baseUrl + 'playgrounds/getPlacesURLforPlayground.json?name=' + encodeURI(name);
		$.ajax({
		   type: 'GET',
		    url: getPlaceUrl,
		    async: false,
			contentType: 'application/json',
			dataType: 'jsonp',
		    success: function(json) {
				caller.apply(null, [json]);
		    },
		    error: function(e) {
		       caller.apply(null, [false]);
		    }
		});
	};

	inst.PlacesApiSearch = function(address, radius, callback) {
		var caller = callback;
		var dist = radius * 5280;

		var placesSearchUrl = inst.baseUrl + 'playgrounds/getPlaygrounds.json?radius=' + dist + '&address=' + encodeURI(address);
		$.ajax({
		   type: 'GET',
		    url: placesSearchUrl,
		    async: false,
			contentType: 'application/json',
			dataType: 'jsonp',
		    success: function(json) {
				caller.apply(null, [json]);
		    },
		    error: function(e) {
		       caller.apply(null, [false]);
		    }
		});
	};

	return inst;
};

google.maps.Circle.prototype.contains = function(latLng) {
  return this.getBounds().contains(latLng) && google.maps.geometry.spherical.computeDistanceBetween(this.getCenter(), latLng) <= this.getRadius();
}