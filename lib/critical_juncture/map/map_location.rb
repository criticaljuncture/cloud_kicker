module Cloudkicker
  module MapLocation
    
    def set_map_center(lat long, zoom, bounds, bound_points, bound_zoom)
      js = []
      
      js << <<-JS
        // check to see if this page has a map location in the url
        if (self.document.location.hash) {
      JS
      
      js << add_bookmarking
      
      js << <<-JS
        // no location present in the url so use the app defaults
        else {
      JS
      
      js << add_default_center(lat, long, zoom, bounds, bound_points, bound_zoom)
      
      js << ' } //close our else from above when checking if a location was present in the url'
      
      return js
    end
    
    def add_bookmarking
      # set up javascript to use map location in url if present (ie it was bookmarked)
      js = <<-JS
            var params = {};
            $.each(self.document.location.hash.split(/&/), function(i, key_and_val){
              var results = key_and_val.split(/=/);
              var key = results[0].replace(/^#/, '');
              var val = results[1];
              params[key] = val;
            });

            // if all the required params are present then set a new map center and zoom
            if (params.center_lat && params.center_lng && params.zoom) {
              map.setCenter(new CM.LatLng(params.center_lat, params.center_lng), params.zoom);
            }
          }
      JS
      
      return js
    end
    
    def add_default_center(lat, long, zoom, bounds, bound_points, bound_zoom)
      js = []
      
      if bounds 
        if bound_points.size > 1
          js << "   map.zoomToBounds(#{bounding_box(bound_points)})"
        else bound_points.size == 1
          js << "   map.setCenter(new CM.LatLng(#{bound_points.first.latitude}, #{bound_points.first.longitude}), #{bound_zoom});"
        end
      else
        js << "   map.setCenter(new CM.LatLng(#{lat}, #{long}), #{zoom});"
      end
    end
    
  end
end