Dir["#{File.join(File.dirname(__FILE__), 'map', '*.rb')}"].each do |filename|
  require filename
end