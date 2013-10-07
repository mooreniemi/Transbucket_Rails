namespace :migrate do
  desc "old users into new users"
  task :user_transfer => :environment do
    #done in sql
    #INSERT INTO users (id, username, encrypted_password, name, gender, email, created_at, updated_at) SELECT ID, username, password, name, sex, email, dateJoined, lastLogin FROM old_users;
  end

  desc "old results into new pins"
  task :result_transfer => :environment do
    #done in sql
    #INSERT INTO `pins` (id, `details`, created_at, `username`, `procedure`, `revision`, `surgeon`, `cost`) SELECT ID, `comments`, dateApproved, `username`, surgeryType, wantRevision, `surgeon`, `cost` FROM results;
  end

  desc "Assign pictures to pins and users"
  task :remodel => :environment do
    #first we need us a list of the pin objects
    pins = Pin.all; nil

    pins.each do |pin|
      #if pin.pin_images.present?
      #	if File.exist?("#{Rails.root}/public/system/pin_images/results/#{Pin.find(pin).username}2.jpg") then
          #this finds the pin then updates the already created empty pin image with the appropriate file path
      #    Pin.find(pin).pin_images.first.update_attributes(:photo => File.new("#{Rails.root}/public/system/pin_images/results/#{Pin.find(pin).username}2.jpg", "r"))
      #  end
      #else
      	if File.exist?("#{Rails.root}/public/system/pin_images/results/#{Pin.find(pin).username}2.jpg") then
      	  Pin.find(pin).pin_images.new(:photo => File.new("#{Rails.root}/public/system/pin_images/results/#{Pin.find(pin).username}2.jpg", "r")).save
      	end
        #end
    end

    #i = 0
    #for pin in pins do
    #	until i == Pin.find(pin).pin_images.length do
    #		if pin.pin_images[i].photo_file_size.nil? then
    #			pin.pin_images[i]
    #		end
    #		i +=1
    #	end
    #end

    pins.each do |pin|
    	pin.update_attribute(:user_id, User.find_by_username(pin.username).id) unless User.find_by_username(pin.username).nil?
    end

  end
end