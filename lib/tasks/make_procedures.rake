namespace :procedure do
  desc "create procedures"
  task :create => :environment do

    bar = RakeProgressbar.new(Pin::FTM.count + Pin::MTF.count)

    Pin::FTM.each {|n| Procedure.new(name: n, gender: 'ftm').save }
    bar.inc
    Pin::MTF.each {|n| Procedure.new(name: n, gender: 'mtf').save }
    bar.inc
    Procedure.all.each {|p| p.type = 'top' && p.save if Pin::TOP.include?(p.name) }
    bar.inc
    Procedure.all.each {|p| p.type = 'bottom' && p.save if Pin::BOTTOM.include?(p.name) }
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