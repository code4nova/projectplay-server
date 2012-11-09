var playApp = function() 
{  
	var inst = {};
	var config = {
		title: "Alexandria Plays",
		startLatLon: [38.818860, -77.091497],
		startZoom: 13,
	    logo: "/assets/aplays.png",
	    playUrl: "http://projectplay.herokuapp.com/"
	};

	inst.lastCircle = null;
	inst.addressCenterPoint = null;
	inst.markers = [];

	inst.initialize = function() {
		var mapCenter = new google.maps.LatLng(config.startLatLon[0], config.startLatLon[1]);
		var zoomLvl = config.startZoom;

		var mapOptions = {
		  zoom: zoomLvl,
		  center: mapCenter,
		  mapTypeId: google.maps.MapTypeId.ROADMAP
		};
		inst.map = new google.maps.Map(document.getElementById('map_canvas'), mapOptions);

		//init branding stuff from app.config
		if (config.logo) {
			$('#header_img').attr('src', config.logo);
		}
		
		if (config.title) {
			document.title = config.title;
		}

		initSidebar();
		inst.svc = playSvc(config.playUrl);
	};

	var initSidebar = function() {
		
		$("#showAllBtn").click(
			function() {
				showAllPlaygrounds();
			}
		);

		$("#addressSearchBtn").click(
			function() {
				searchByAddress();
			}
		);

		/*$("#search").append("<div><input id='loc_auto' type='text' /></div>");

		var input = document.getElementById('searchTextField');
        var autocomplete = new google.maps.places.Autocomplete(input);
        autocomplete.bindTo('bounds', inst.map);
        var infowindow = new google.maps.InfoWindow();
        var marker = new google.maps.Marker({
          map: inst.map
        });

        google.maps.event.addListener(autocomplete, 'place_changed', function() {
          infowindow.close();
          var place = autocomplete.getPlace();
          if (place.geometry.viewport) {
            inst.map.fitBounds(place.geometry.viewport);
          } else {
            inst.map.setCenter(place.geometry.location);
            inst.map.setZoom(17);  // Why 17? Because it looks good.
          }

          var image = new google.maps.MarkerImage(
              place.icon,
              new google.maps.Size(71, 71),
              new google.maps.Point(0, 0),
              new google.maps.Point(17, 34),
              new google.maps.Size(35, 35));
          marker.setIcon(image);
          marker.setPosition(place.geometry.location);

          var address = '';
          if (place.address_components) {
            address = [
              (place.address_components[0] && place.address_components[0].short_name || ''),
              (place.address_components[1] && place.address_components[1].short_name || ''),
              (place.address_components[2] && place.address_components[2].short_name || '')
            ].join(' ');
          }

          infowindow.setContent('<div><strong>' + place.name + '</strong><br>' + address);
          infowindow.open(inst.map, marker);
        });*/
	};

	var showAllPlaygrounds = function() {
		clearCircle();
		clearMarkers();
		inst.svc.getAllPlaygrounds(function(data) { renderPlaygrounds(data); zoomToMarkerBounds();});
	};

	var searchByAddress = function() {
		clearCircle();
		clearMarkers();
		var address = $('#inputAddress').val();
		inst.svc.geoCodeAddress(address, function(data) { renderAddressSearch(data); });
	}

	var renderAddressSearch = function(results) {
		var pt = new google.maps.LatLng(results.geometry.location.lat(), results.geometry.location.lng());
		var name = results.formatted_address;
		inst.addressCenterPoint = new google.maps.Marker({
		            position: pt,
		            map: inst.map,
		            title: name,
		            //icon: image
		        });
		inst.map.setCenter(pt);

		var dist = parseInt($('#inputDistance').val(), 10);
		console.log(dist);
		var circleOptions = {
	      strokeColor: "#ff0000",
	      strokeOpacity: 0.7,
	      strokeWeight: 1,
	      fillColor: "#00ff21",
	      fillOpacity: 0.1,
	      map: inst.map,
	      center: pt,
	      radius: dist * 1609.344
	    };

	    inst.lastCircle = new google.maps.Circle(circleOptions);
	    inst.svc.getAllPlaygrounds(renderPlaygrounds);
	}

	var clearMarkers = function() {
	  for (var i = 0; i < inst.markers.length; i++ ) {
	    inst.markers[i].setMap(null);
	  }
	};

	var clearCircle = function() {
		if (inst.lastCircle) {
		  	inst.lastCircle.setMap(null);
		  	inst.lastCircle = null;
		}
		if (inst.addressCenterPoint) {
			inst.addressCenterPoint.setMap(null);
			inst.addressCenterPoint = null;
		}
	};

	var renderPlaygrounds = function(playData) {
		if (playData) {
			for (var i = 0; i < playData.length; i++) {
				var playObj = playData[i];
				//console.log(playObj);

				var image = new google.maps.MarkerImage('/assets/playground_marker.png',
						new google.maps.Size(32, 37), //icon size
					    new google.maps.Point(0,0), //origin
					    new google.maps.Point(16, 37) //offset
					);
				var pt = new google.maps.LatLng(playObj.lat, playObj.long);
				
				var addMarker = function() {
					var marker = new google.maps.Marker({
			            position: pt,
			            map: inst.map,
			            title: playObj.name,
			            icon: image
			        });
			        inst.markers.push(marker);
				}

				if (inst.lastCircle) {
					if (inst.lastCircle.contains(pt)) {
						addMarker();
					}
				}
				else {
					addMarker();
				}
			}
		}
	};

	var zoomToMarkerBounds = function() {
		var bounds = new google.maps.LatLngBounds();
		var extent = [];
		for (var i = 0; i < inst.markers.length; i++ ) {
	    	//console.log(inst.markers[i]);
	    	//extent.push(inst.markers[i].position.Ya, inst.markers[i].position.Za);
	    	bounds.extend(inst.markers[i].position);
	    }
	    
	    inst.map.fitBounds(bounds);
	    var listener = google.maps.event.addListener(inst.map, "idle", function() { 
		  if (inst.map.getZoom() > 16) inst.map.setZoom(16); 
		  google.maps.event.removeListener(listener); 
		});
	};

	return inst;
};




