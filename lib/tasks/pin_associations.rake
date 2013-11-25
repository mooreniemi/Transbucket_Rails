namespace :pins do
  desc "give pins procedure associations"
  task :associate_procedure => :environment do
    pins = Pin.all

    pins.each do |p|
      p.procedure_id = Procedure.find_by_name(p.procedure_id).id if Procedure.find_by_name(p.procedure_id).present?
      p.save(validate: false)
    end
  end

  desc "give pins surgeon associations"
  task :associate_surgeon => :environment do
    pins = Pin.all
    pins.each do |p|

      surgeon = p.surgeon_id.downcase.split(',').first
      match_pool = []

      last_names = Surgeon.pluck(:last_name).map(&:downcase)
      last_names.each {|n| match_pool << n if /#{surgeon}/.match(n).present? }

      if match_pool.count == 1
        match = Surgeon.find_by_last_name(match_pool.first)
        p.surgeon_id = match.id if match.present?
        p.save(validate: false)
      end
    end

  end

  desc "give pins with multiple matches a surgeon"
  task :which_johnson => :environment do
    perry = Pin.where(surgeon_id: "Johnson, Perry")
    melissa = Pin.where(surgeon_id: "Johnson, Melissa")

    perry.each {|p| p.surgeon_id = 49; p.save}
    melissa.each {|p| p.surgeon_id = 7; p.save}
  end

  desc "create surgeons where necessary"
  task :new_surgeon => :environment do
    pins = Pin.all

    pins.each do |pin|
      unless pin.surgeon_id == 'other' || pin.surgeon_id.length < 3
        Surgeon.new(last_name: pin.surgeon_id).save!
      end
    end
  end

end