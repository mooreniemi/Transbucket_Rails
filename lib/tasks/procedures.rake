namespace :procedure do
  desc "old procedures into new procedures"
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

  desc "translate surgeon procedures field"
  task :surgeon_list => :environment do
    procedures = Procedure.pluck(:name).map(&:downcase)
    surgeons = Surgeon.all
    bar = RakeProgressbar.new(surgeons.count)

    surgeons.each do |surgeon|

      match_pool = []

      procedure_list = surgeon.procedure_list

      unless procedure_list.blank?
        procedure_list = procedure_list.split(',')
        procedure_list.reject! {|e| e.blank? }
        procedure_list.map!(&:downcase)
        procedure_list.each {|e| e.gsub!(/\A\s/, '')}
        procedure_list = procedure_list.uniq

        procedure_list.each {|n| match_pool << n if procedures.include?(n) }
      end

      if match_pool.count > 0
        match_pool.each {|m| Skill.new(surgeon_id: surgeon.id, procedure_id: Procedure.find_by_name(m).id ).save! if Procedure.find_by_name(m).present? }
      end
      bar.inc
    end

    bar.finished

  end
end