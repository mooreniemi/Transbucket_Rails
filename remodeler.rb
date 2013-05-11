#first we need us a list of the pin objects
pins = Pin.all; nil

#simplest loop of all times
for pin in pins do

#this finds the pin then updates the already created empty pin image with the appropriate file path
Pin.find(pin).pin_images.first.update_attributes(:photo => File.new("/Users/Alex/Documents/Code/TB_Rails_M/public/system/pin_images/results/#{Pin.find(pin).username}1.jpg", "r"))

end

for pin in pins do
	if File.exist?("/Users/Alex/Documents/Code/TB_Rails_M/public/system/pin_images/results/#{Pin.find(pin).username}1.jpg") then
	Pin.find(pin).pin_images.new(:photo => File.new("/Users/Alex/Documents/Code/TB_Rails_M/public/system/pin_images/results/#{Pin.find(pin).username}1.jpg", "r")).save
	end
end