h = Builder::XmlMarkup.new(
   :indent => 2
 )
 
 class <<h
   def link!( url, text )
     a( {:href => url}, text )
   end
 end
 
 html = h.link!( 'http://ruby.about.com', 'Ruby' )
 puts html