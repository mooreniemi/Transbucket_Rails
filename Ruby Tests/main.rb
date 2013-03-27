get '/my_template' do
  @weather = "sunny"
  @temperature = 80
  haml :weather
end
view rawmain.rb