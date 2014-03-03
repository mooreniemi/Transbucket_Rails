namespace :genders do
  desc "create genders"
  task :create => :environment do

    genders = ["FTM", "MTF", "GenderQueer", "None", "Cisgender"]
    bar = RakeProgressbar.new(genders.count)

    genders.each do |g|
      gender = Gender.new(name: g)
      gender.save!
      bar.inc
    end

    bar.finished

  end
end