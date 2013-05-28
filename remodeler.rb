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

i = 0
for pin in pins do
	until i == Pin.find(pin).pin_images.length do
		if pin.pin_images[i].photo_file_size.nil? then
			pin.pin_images[i]
		end
		i +=1
	end
end

for pin in pins do
	pin.update_attribute(:user_id, User.find_by_username(pin.username).id) unless User.find_by_username(pin.username).nil?
end
