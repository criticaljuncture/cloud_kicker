module Cloudkicker
  class Map
    include Cloudkicker::ControlElements
    include Cloudkicker::MapLocation
    include Cloudkicker::MapBookmarking
    include Cloudkicker::MapEvents
    include Cloudkicker::AjaxMarkers
    
    def initialize(options={})
      configure
      
      @lat                       = options.delete(:lat)                || @ck_config['map']['lat']
      @long                      = options.delete(:long)               || @ck_config['map']['long']
      @map_control               = options.delete(:map_control)        || @ck_config['map']['map_control']['visible']
      @map_control_type          = options.delete(:map_control_type)   || @ck_config['map']['map_control']['type'].to_sym
      @zoom                      = options.delete(:zoom)               || @ck_config['map']['zoom']
      @style_id                  = options.delete(:style_id)           || @ck_config['map']['style']['id']
      @bounds                    = options.delete(:bounds)             || @ck_config['map']['bounds']['enabled']
      @bound_points              = options.delete(:points)             || 0
      if @bounds && @bound_points == 0
        raise "You must provide at least one point (via :bound_points) if you are using bounds set to true"
      end
      @bound_zoom                = options.delete(:bound_zoom)         || @ck_config['map']['bounds']['zoom'] #used when only a single point is passed to bound_points
      @enable_bookmarking        = options.delete(:enable_bookmarking) || @ck_config['map']['bookmarking']['enabled']
      @ajax_markers              = options.delete(:ajax_markers)       || @ck_config['map']['markers']['ajax']['enabled']
      @ajax_url                  = options.delete(:ajax_url)           || @ck_config['map']['markers']['ajax']['url']
      @markers                   = []
      @scroll_wheel_zoom_enabled = options.delete(:scroll_wheel_zoom_enabled) || @ck_config['map']['scroll_wheel_zoom']['enabled']
    end
    
    def configure
      app_root   = RAILS_ROOT if defined?(RAILS_ROOT)
      @ck_config = YAML.load( File.open("#{app_root}/config/cloud_kicker.yml", 'r') )
    end
    
    def to_js(map_id='map')
      js = []
      # get the cloudmade map js
      js << <<-JS
        <script type=\"text/javascript\" src=\"#{CLOUDMADE_SRC}\"></script>
      JS

      js << '<script type="text/javascript">'
      
      js << <<-JS
        // set up the array of added markers for use later
        var addedMarkers = [];
      JS

      # create the script that will create and manage the map
      js << <<-JS
          $(document).ready(function() {
            
            // create a new cloudmade tile object with our api key and the map style we want
            var cloudmade = new CM.Tiles.CloudMade.Web({key: '#{CLOUDMADE_API_KEY}', styleId: #{@style_id}});
            
            // create a new map object on the DOM element reference by map_id and the tile object above
            var map = new CM.Map('#{map_id}', cloudmade);
    
            // set up options here like turning on or off certain map features or setting the map center
      JS
      
      unless @scroll_wheel_zoom_enabled
        js << <<-JS   
            map.disableScrollWheelZoom();
        JS
      end
      
      if @map_control
        js << add_map_control(@map_control_type)
      end
      
      # add listenters for events
      js << add_events(:ajax_markers => @ajax_markers, 
                       :enable_bookmarking => @enable_bookmarking)
      
      # set center of map properly 
      # (must come after any listeners for map load - setting the center is what triggers the event it)
      js << set_map_center(@lat, @long, @zoom, @bounds, @bound_points, @bound_zoom)
      
      
      unless @ajax_markers
        @markers.each do |marker|
          js << marker
        end
      end
      
      js << '}); //end $(document).ready'
      
      # add the functions we'll need (for events, etc)
      if @ajax_markers
        js << add_ajax_marker_functions(@ajax_url)
      end
      
      if @enable_bookmarking
        js << add_bookmarking_functions
      end
      
      js << '</script>'
      js.join("\n")
    end
    
    def markers
      @markers
    end
    
    def bounding_box(points)
      # lats  = []
      # longs = []
      # points.each do |point|
      #   lats  << point.latitude
      #   longs << point.longitude
      # end
      # 
      # max_lat = lats.max
      # min_lat = lats.min
      # max_long = longs.max
      # min_long = longs.min
      # 
      # north_east_lat  = max_lat  + (max_lat  - min_lat)
      # north_east_long = max_long + (max_long - min_long)
      # 
      # south_west_lat  = min_lat  - (max_lat  - min_lat)
      # south_west_long = min_long - (max_long - min_long)
      
      cloud_map_points = []
    
      points.each do |point|
        cloud_map_points << "new CM.LatLng(#{point.latitude}, #{point.longitude})"
      end
      
      "new CM.LatLngBounds(#{cloud_map_points.join(',')})"
    end
  end
  
end