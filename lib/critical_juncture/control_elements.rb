module Cloudkicker
  module ControlElements
    
    # add create a map control with type, position and padding
    #
    # Params:
    #   map_control_type
    #     The size of the control on the map
    #     Options - :large, :small
    #   position
    #     Where the control is located on the map
    #     Options - :top_right
    #   padding_x
    #     Amount of padding in the x direction in pixels - depends on where the position is set to, 
    #     but always from the outer edge of the map
    #   padding_y
    #     Amount of padding in the y direction in pixels - depends on where the position is set to, 
    #     but always from the outer edge of the map
    
    def add_map_control(map_control_type, position = :top_right, padding_x = 10, padding_y = 10)
      control_position =  case position
                          when :top_right
                            'CM.TOP_RIGHT'
                          end
      
      control_type =  case @map_control_type.to_sym
                      when :large
                         'CM.LargeMapControl()'
                      when :small
                        'CM.SmallMapControl()'
                      end
      
      js = <<-JS
        // create a new control position and add padding
        var control_position = new CM.ControlPosition(#{control_position}, new CM.Size(#{padding_x}, #{padding_y}));
        map.addControl(new #{control_type}, #{control_position});
      JS
      
      return js
    end
  end
end