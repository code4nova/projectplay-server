var playApp = function() 
{  
	var inst = {};
	var config = {
		title: "Alexandria Plays",
		startLatLon: [38.818860, -77.091497],
		startZoom: 13,
	    logo: "/assets/aplays.png",
	    //playUrl: "localhost:3000"
	    playUrl: "http://alexandriaplays.codefornova.org/"
	};

	inst.lastCircle = null;
	inst.addressCenterPoint = null;
	inst.markers = [];
	inst.lastSearchResults = [];
	inst.mapToolTip = null;

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

		$(app_listview).click(clickPgList);

		initSidebar();
		inst.svc = playSvc(config.playUrl);

		inst.mapToolTip = new google.maps.InfoWindow();
	};

	var clickPgList = function(e) {
		var target = e.target;

		var limit = 5;
		while (limit > 0 && target.tagName.toLowerCase() != "td") {
			target = target.parentNode;
			limit--;
		}
		//console.log(target);

		renderDetailModal(target.id);
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
				//searchByAddressWithPlacesApi();
			}
		);

		$("#app_listview").hide();
		$("#app_pager").hide();
	};

	var clearAll = function() {
		clearCircle();
		clearMarkers();
		clearListView();
		inst.lastSearchResults = [];	
	};

	var showAllPlaygrounds = function() {
		clearAll();
		inst.svc.getAllPlaygrounds(function(data) { renderPlaygrounds(data); zoomToMarkerBounds();});
	};

	var searchByAddress = function() {
		clearAll();
		var address = $('#inputAddress').val();
		inst.svc.geoCodeAddress(address, function(data) { renderAddressSearch(data); });
	};

	var searchByAddressWithPlacesApi = function() {
		clearAll();
		var address = $('#inputAddress').val();
		var dist = parseInt($('#inputDistance').val(), 10);
		inst.svc.PlacesApiSearch(address, dist, function(data) { renderAddressApiSearch(data); });
		inst.svc.geoCodeAddress(address, function(data) { renderSearchCircle(data); });
	};

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
		//console.log(dist);
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
	};

	var renderSearchCircle = function(results) {
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
		//console.log(dist);
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
	};

	var renderAddressApiSearch = function(results) {
		renderMarkers(results);
		renderListView(results);
		inst.lastSearchResults = results;
	    //inst.svc.getAllPlaygrounds(renderPlaygrounds);
	};

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

	var clearListView = function() {
		$('#listTbl').html("");
		$('#app_pager').hide();
	};

	var renderPlaygrounds = function(playData) {
		if (playData) {
			var filteredList = [];
			for (var i = 0; i < playData.length; i++) {
				var playObj = playData[i];
				//console.log(playObj);

				var pt = new google.maps.LatLng(playObj.lat, playObj.long);
				if (inst.lastCircle) {
					if (inst.lastCircle.contains(pt)) {
						filteredList.push(playObj);
					}
				}
				else {
					filteredList.push(playObj);
				}
			}
			inst.lastSearchResults = filteredList;
			renderMarkers(filteredList);
			renderListView(filteredList);
		}
	};

	inst.clickPgMarker = function(id) {
		renderDetailModal(id);
	};

	var renderDetailModal = function(id) {
		for (var i = 0; i < inst.lastSearchResults.length; i++) {
			var result = inst.lastSearchResults[i];

			if (id == result.id) {
				//console.log(result);

				//title
				$('#detail_title').empty();
				$('#detail_title').append(result.name);

				//age level
				$('#detail_agelevel_text').empty();
				$('#detail_agelevel_text').append(result.agelevel);

				//restrooms
				$('#detail_restrooms').empty();
				if (result.restrooms == 1) {
					$('#detail_restrooms').append('None.');
				} 
				else if (result.restrooms == 2) {
					$('#detail_restrooms').append('Inadequate.');
				}
				else if (result.restrooms == 3) {
					$('#detail_restrooms').append('Plenty.');
				}

				//drinking fountain
				$('#detail_drinkingfountain').empty();
				if (result.drinkingw == 1) {
					$('#detail_drinkingfountain').append('None.');
				}
				else if (result.drinkingw == 2) {
					$('#detail_drinkingfountain').append('Limited.');
				}
				else if (result.drinkingw == 3) {
					$('#detail_drinkingfountain').append('As much as you want.');
				}

				//seating
				$('#detail_seating').empty();
				if (result.seating == 1) {
					$('#detail_seating').append('Little to no seating.');
				}
				else if (result.seating == 2) {
					$('#detail_seating').append('Inadequate.');
				}
				else if (result.seating == 3) {
					$('#detail_seating').append('Adequate.');
				}

				//comments
				$('#detail_comments_text').empty();
				$('#detail_comments_text').append(result.generalcomments);

				//get google places url
				$('#detail_googleplacelink').empty();
				$('#detail_googleplacelink').append('loading...');
				var placesURL = inst.svc.getPlaceUrl(result.name,
					function(json) {
						//console.log(json.url);
						if (json.url) {
							$('#detail_googleplacelink').empty();
							$('#detail_googleplacelink').append("<a href=" + json.url + " target='new'>Click Here.</a>");
						}
						else {
							$('#detail_googleplacelink').empty();
							$('#detail_googleplacelink').append("N/A");
						}
						
					}
				);
			}
		}

		$('#app_detail_modal').modal();

	};

	var zoomToMarkerBounds = function() {
		var bounds = new google.maps.LatLngBounds();
		var extent = [];
		for (var i = 0; i < inst.markers.length; i++ ) {
	    	bounds.extend(inst.markers[i].position);
	    }
	    
	    inst.map.fitBounds(bounds);
	};

	var renderMarkers = function(list) {
		for (var i = 0; i < list.length; i++) {
			var playObj = list[i];

			var image = new google.maps.MarkerImage('/assets/playground_marker.png',
						new google.maps.Size(32, 37), //icon size
					    new google.maps.Point(0,0), //origin
					    new google.maps.Point(16, 37) //offset
					);
			var pt = new google.maps.LatLng(playObj.lat, playObj.long);
			
			var addMarker = function() {
				var marker = new google.maps.Marker({
		            id: playObj.id,
		            position: pt,
		            map: inst.map,
		            name: playObj.name,
		            icon: image
		        });
		        //marker.set("id", playObj.id);
		        inst.markers.push(marker);
		        
		        google.maps.event.addListener(marker, 'click', 
		        		function (e) {
		        			inst.clickPgMarker(marker.id);
		        		}
		        );

		        google.maps.event.addListener(marker, "mouseover", function(event) {
                	this.setIcon('/assets/playground_marker_green.png');
                	$('#' + this.id).css('background-color', '#aedd52');

                	inst.mapToolTip.setContent('<p><strong>' + this.name + '</strong></p>');
                	inst.mapToolTip.open(inst.map, this);
                });

                google.maps.event.addListener(marker, "mouseout", function(event) {
                	this.setIcon('/assets/playground_marker.png');
                	$('#' + this.id).css('background-color', '');
                	inst.mapToolTip.close();
                });
			}

			addMarker();
		}
	};

	var renderListView = function(list) {
		if (list.length > 0) 
		{
			$("#app_listview").show();
			$("#app_pager").show();
			for (var i = 0; i < list.length; i++) {
				var listItem = list[i];
				var builder = [];
				builder.push("<tr>");
				builder.push("	<td ");
				builder.push(" id='");
				builder.push(listItem.id);
				builder.push("' ");
				builder.push(" class='listViewRow'>");
				builder.push("		<strong>" + listItem.name + "</strong>");
				builder.push("		<i class='icon-info-sign right'></i>");
				builder.push("  </td>");
				builder.push("</tr>");
				$('#listTbl').append(builder.join(""));
			}

			inst.rightSizeListView();
			$('.listViewRow').hover(
				function() {
					$(this).css('background-color', '#aedd52');
					for (var i = 0; i < inst.markers.length; i++) {
						var m = inst.markers[i];
						if (m.id == this.id) {
							m.setIcon('/assets/playground_marker_green.png');
							inst.mapToolTip.setContent('<p><strong>' + m.name + '</strong></p>');
                			inst.mapToolTip.open(inst.map, m);
						}
					}
				},
				function() {
					$(this).css('background-color', '');
					for (var i = 0; i < inst.markers.length; i++) {
						var m = inst.markers[i];
						if (m.id == this.id) {
							m.setIcon('/assets/playground_marker.png');
							inst.mapToolTip.close();
						}
					}
				}
			);

		} 
	};

	inst.rightSizeListView = function() {
		var h = $(window).height();
		$("#app_listview").css("height",  h - 290 + "px");
	};

	return inst;
};






