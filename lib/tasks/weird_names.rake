namespace :surgeons do
  desc "old surgeons into new surgeons that have weird names"
  task :weird_names => :environment do

    surgeons = OldSurgeon.all
    weird_names = []
    surgeons.each {|s| weird_names << s if s.SurgeonName.split.length > 2}
    weird_names.each {|s| s.SurgeonName.gsub!(/(dr.|Dr.|dr|Dr|MD|md|M.D.|FRCS)/, '')}

    bar = RakeProgressbar.new(weird_names.count)

    weird_names.each do |u|
      #:surgeonname, :address, :city, :state, :zip, :country, :phone, :email, :url, :procedures, :notes
      #:address, :city, :country, :email, :id, :first_name, :last_name, :phone, :procedures, :state, :url, :zip, :notes

      if Surgeon.where(id: u.id).blank?
        Surgeon.new(id: u.id, email: u.Email, first_name: u.SurgeonName.split(',').last, last_name: u.SurgeonName.split(',').first,
                  phone: u.Phone, url: u.URL, procedure_list: u.Procedures, notes: u.Notes,
                  zip: u.ZIP, city: u.City, country: u.Country, address: u.Address ).save(:validate => false)
      end
      bar.inc
    end

    p weird_names.count.to_s + " weird names converted."
  end
end