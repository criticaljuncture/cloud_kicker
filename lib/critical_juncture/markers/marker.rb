module Cloudkicker
  class Marker
    
    def initialize(options={})
      raise 'Map is required'  unless options[:map]
      raise 'Lat is required'  unless options[:lat]
      raise 'Long is required' unless options[:long]
      @map   = options.delete(:map)
      @lat   = options.delete(:lat)
      @long  = options.delete(:long)
      @id    = self.object_id
      @title = options.delete(:title) || ''
      @info  = options.delete(:info)  || ''
      
      
      @info.gsub!(/\s+/, ' ')
      @max_width = options.delete(:info_max_width) || 400
      add_marker
    end
    
    private
    
    def add_marker
      js = []
      js << create_marker(@id, @lat, @long, @title)
      js << add_info_window_to_marker(@id, @info, @max_width)
      js << ''
      # js << '   map.setCenter(myMarkerLatLng, 14);'
      js << "   map.addOverlay(myMarker_#{@id});"
      
      @map.markers << js.join("\n")
    end
    
    def create_marker(id, lat, long, title)
      <<-JS
         var myMarkerLatLng_#{id} = new CM.LatLng(#{lat},#{long});
         var icon = new CM.Icon();
         
         icon.image  = "/images/map_marker.png";
         icon.iconSize = new CM.Size(31, 48);
         icon.shadow  = "/images/map_marker_shadow.png";
         icon.shadowSize = new CM.Size(31, 48);
         icon.iconAnchor = new CM.Point(20, 48);
      
         var myMarker_#{id} = new CM.Marker(myMarkerLatLng_#{id}, {
           title: '#{title}',
           icon: icon
         });
      JS
    end
    
    def add_info_window_to_marker(id, info, max_width)
      # Add listener to marker
      # TODO single quotes should be esacaped not deleted. Escaping doesn't seem to be working at the moment though... clearly missing something
      <<-JS
        CM.Event.addListener(myMarker_#{id}, 'click', function(latlng) {
          map.openInfoWindow(myMarkerLatLng_#{id}, '#{info.gsub(/'/,"")}', {maxWidth: #{max_width}, pixelOffset: new CM.Size(-8,-50)});
        });
      JS
    end
    
  end
end