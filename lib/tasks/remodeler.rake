namespace :migrate do
  desc "old users into new users"
  task :user_transfer => :environment do
    #done in sql
    #INSERT INTO users (id, username, encrypted_password, name, gender, email, created_at, updated_at) SELECT ID, username, password, name, sex, email, dateJoined, lastLogin FROM old_users;

    old_users = OldUser.all
    bar = RakeProgressbar.new(old_users.count)

    #cycle through the old users and create a new user using old user attributes
    old_users.each do |u|
      User.new(id: u.id, email: u.email, created_at: u.dateJoined, updated_at: u.lastLogin, username: u.username, gender: u.sex, password: u.password ).save
      bar.inc
    end
    bar.finished

  end

  desc "old results into new pins"
  task :result_transfer => :environment do
    #done in sql
    #INSERT INTO `pins` (id, `details`, created_at, `username`, `procedure`, `revision`, `surgeon`, `cost`) SELECT ID, `comments`, dateApproved, `username`, surgeryType, wantRevision, `surgeon`, `cost` FROM results;

    #where a result exists with no matching pin id, group those result ids
    results = Result.all; nil

    todo = []

    results.each do |result|
      if Pin.find_by_id(result.id).nil?
        todo << result
      end
    end

    #cycle through the results and create a pin using result attributes
    bar = RakeProgressbar.new(todo.count)

    todo.each do |result|
      Pin.new(id: result.id, details: result.comments, surgeon: result.surgeon, cost: result.cost, procedure: result.surgeryType, created_at: result.dateApproved, username: result.username, revision: result.wantRevision).save
      bar.inc
    end
    bar.finished

  end

  desc "Assign pictures to pins and users"
  task :remodel => :environment do
    results = Result.all; nil

    todo = []

    results.each do |result|
      if Pin.find_by_id(result.id).present?
        todo << result
      end
    end

    bar = RakeProgressbar.new(todo.count)

    todo.each do |result|
      if File.exists?("#{Rails.root}/public/system/results#{result.img1}") && File.directory?("#{Rails.root}/public/system/results#{result.img1}") == false
    	  Pin.find(result.id).pin_images.new(:photo => File.new("#{Rails.root}/public/system/results#{result.img1}", "r"), :caption => result.img1com).save unless result.img1.nil? || Pin.find_by_id(result.id).nil?
      end
      if File.exists?("#{Rails.root}/public/system/results#{result.img2}") && File.directory?("#{Rails.root}/public/system/results#{result.img2}") == false
    	  Pin.find(result.id).pin_images.new(:photo => File.new("#{Rails.root}/public/system/results#{result.img2}", "r"), :caption => result.img2com).save unless result.img2.nil? || Pin.find_by_id(result.id).nil?
      end
      if File.exists?("#{Rails.root}/public/system/results#{result.img3}") && File.directory?("#{Rails.root}/public/system/results#{result.img3}") == false
    	  Pin.find(result.id).pin_images.new(:photo => File.new("#{Rails.root}/public/system/results#{result.img3}", "r"), :caption => result.img3com).save unless result.img3.nil? || Pin.find_by_id(result.id).nil?
      end
      if File.exists?("#{Rails.root}/public/system/results#{result.img4}") && File.directory?("#{Rails.root}/public/system/results#{result.img4}") == false
    	  Pin.find(result.id).pin_images.new(:photo => File.new("#{Rails.root}/public/system/results#{result.img4}", "r"), :caption => result.img4com).save unless result.img4.nil? || Pin.find_by_id(result.id).nil?
      end
      bar.inc
    end
    bar.finished

    puts "Users now"

    results.each do |result|
      Pin.find(result.id).update_attribute(:user_id, User.find_by_username(result.username).id) unless User.find_by_username(result.username).nil?
    end

  end
end