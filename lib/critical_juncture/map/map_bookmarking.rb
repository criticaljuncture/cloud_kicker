module Cloudkicker
  module MapBookmarking
    def add_bookmarking_functions
      add_location_to_anchor
    end
    
    private
    
    def add_location_to_anchor
      <<-JS
        function add_location_to_anchor(map){
          var center = map.getCenter();
          var anchor = '#center_lat=' + center.lat() + '&center_lng=' + center.lng() + '&zoom=' + map.getZoom();
          window.location.hash = anchor;
          return false;
        }
      JS
    end
  end
end