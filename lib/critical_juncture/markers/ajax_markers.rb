module Cloudkicker
  module AjaxMarkers
    
    def add_ajax_marker_functions(url)
      js = []
      js << add_marker_function
      js << get_map_points_function(url)
      return js
    end
    
    def add_marker_function
      <<-JS
      function add_markers(markers) {
        $.each(added_markers, function(i, added_marker){
          map.removeOverlay(added_marker);
        });
        added_markers = [];
      
        $.each(markers, function(i, marker){
          var myMarkerLatLng = new CM.LatLng(marker.lat,marker.lng);

          var icon = new CM.Icon();
          if(marker.tower) {
            icon.image  = "/images/dot_med.png";
          }
          else
          {
            icon.image  = "/images/dot_med_blue.png";
          }
        
          icon.iconSize = new CM.Size(21, 21);
          //icon.shadow  = "/images/map_marker_shadow.png";
          //icon.shadowSize = new CM.Size(31, 48);
          //icon.iconAnchor = new CM.Point(20, 48);

          var myMarker = new CM.Marker(myMarkerLatLng, {
            title: marker.licensee,
            icon: icon
          });
        
          CM.Event.addListener(myMarker, 'click', function(latlng){
            if(marker.tower) {
              map.openInfoWindow(myMarkerLatLng, parseTemplate($("#cell_tower_template").html(), marker), {maxWidth: 400, pixelOffset: new CM.Size(0,-10)});
            }
            else
            {
              map.openInfoWindow(myMarkerLatLng, parseTemplate($("#cell_site_template").html(), marker), {maxWidth: 400, pixelOffset: new CM.Size(0,-10)});
            }
          });
        
        
          added_markers.push(myMarker);
          map.addOverlay(myMarker);
        });
      
        $('.mapMarkerLoader img').hide();
      }
      JS
    end
    
    def get_map_points_function(url)
      <<-JS
      function getMapPoints(CMBounds) {
        var sw_CMLatLng = CMBounds.getSouthWest();
        var sw_point    = [sw_CMLatLng.lat(), sw_CMLatLng.lng()]
        var ne_CMLatLng = CMBounds.getNorthEast();
        var ne_point    = [ne_CMLatLng.lat(), ne_CMLatLng.lng()]  

        $.ajax({
          type:"GET",
          url:'#{url}',
          data:"per_page=200&fields=limited&search[conditions][descend_by_created_at]=1&search[conditions][within_bounds][sw_point][]=" + sw_point[0] + "&search[conditions][within_bounds][sw_point][]=" + sw_point[1] + "&search[conditions][within_bounds][ne_point][]=" + ne_point[0] + "&search[conditions][within_bounds][ne_point][]=" + ne_point[1],
          dataType:'json',
          success: add_markers
        });
      }

      JS
    end
    
  end
end