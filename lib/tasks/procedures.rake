namespace :procedure do
  desc "old users into new users"
  task :consolidate => :environment do

    #original list
    #["Breast Augmentation/Implants", "Periareolar/Keyhole", "MTF Bottom Surgery", "FTM Phalloplasty", "T Anchor Double Incision", "Other", "Double incision w/ NO nipple grafts", "FFS/Facial Feminization Surgery", "FTM Metoidioplasty", "Double Incision w/ NO Nipple Grafts", "", "Double Incision w/ nipple grafts"]

    #new list
    #["vaginoplasty", "breast augmentation", "phalloplasty", "facial feminization surgery", "periareolar mastectomy (keyhole)", "double incision without grafts", "double incision with grafts", "metoidioplasty", "t anchor double incision", "other"]

    pins = Pin.all
    bar = RakeProgressbar.new(pins.count)

    new_names = {
      "Breast Augmentation/Implants" => "breast augmentation",
      "Periareolar/Keyhole" => "periareolar mastectomy (keyhole)",
      "MTF Bottom Surgery" => "vaginoplasty",
      "FTM Phalloplasty" => "phalloplasty",
      "T Anchor Double Incision" => "t anchor double incision",
      "Other" => "other",
      "Double incision w/ NO nipple grafts" => "double incision without grafts",
      "Double Incision w/ NO Nipple Grafts" => "double incision without grafts",
      "Double Incision w/ nipple grafts" => "double incision with grafts",
      "FFS/Facial Feminization Surgery" => "facial feminization surgery",
       "FTM Metoidioplasty" =>  "metoidioplasty",
       "" => "other"
    }

    pins.each {|pin| pin.procedure = new_names[pin.procedure]; pin.save(validate: false); bar.inc}
    bar.finished

  end
end