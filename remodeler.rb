for pin in pins do

Pin.find(pin).pin_images.first.update_attributes(:photo => File.new("/Users/Alex/Documents/Code/TB_Rails_M/public/system/pin_images/results/#{Pin.find(pin).username}1.jpg", "r")).save