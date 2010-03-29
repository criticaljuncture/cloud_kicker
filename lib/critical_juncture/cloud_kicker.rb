require 'map'
require 'control_elements'

Dir["#{File.join(File.dirname(__FILE__), 'map', '*.rb')}"].each do |filename|
  require filename
end

Dir["#{File.join(File.dirname(__FILE__), 'markers', '*.rb')}"].each do |filename|
  require filename
end