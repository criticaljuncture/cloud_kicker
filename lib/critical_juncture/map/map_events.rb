module Cloudkicker
  module MapEvents
    
    def add_events(options={})
      ajax_markers       = options.delete(:ajax_markers)
      enable_bookmarking = options.delete(:enable_bookmarking)
      
      js = []
      js << <<-JS
            /*************************/
            /* add events to the map */
            /*************************/
      JS
      
      if ajax_markers
        js << ajax_markers_event
      end
      
      js << map_drag_event(enable_bookmarking)
      
      return js.join('\n')
    end
    
    
    # Fires on map load and uses the ajax markers module to get markers from server
    def ajax_markers_event
      js = <<-JS
        // get the markers for the area shown in the map (the bounds) on load
        CM.Event.addListener(map, 'load', function() {
          getMapPoints(map.getBounds());
        });
      JS
      
      return js
    end
    
    def map_drag_event(enable_bookmarking)
      js = []
  
      js << <<-JS
            // we get markers dynamically from the server 
            // first turn on the loading indicator
            $('.mapMarkerLoader img').show();
      
            // show the map marker loading indicator and get the markers for the area shown in 
            // the map (the bounds)
            CM.Event.addListener(map, 'dragend', function() {
              $('.mapMarkerLoader img').show();
              getMapPoints(map.getBounds());
      JS
      
      # if we're bookmarking then add the location to the url
      if enable_bookmarking
        js << <<-JS
                //and add the new map location to the url so it's bookmarkable
                add_location_to_anchor(map);
        JS
      end
      
      # close our dragend map listener regarless
      js << <<-JS
              });
      JS
      
      return js.join('\n')
    end
    
  end
end