namespace :surgeons do
  desc "old surgeons into new surgeons"
  task :surgeon_transfer => :environment do

    surgeons = OldSurgeon.all
    regular_names = []
    surgeons.each {|s| regular_names << s if s.SurgeonName.split.length == 2}

    bar = RakeProgressbar.new(regular_names.count)

    regular_names.each do |u|
      #:surgeonname, :address, :city, :state, :zip, :country, :phone, :email, :url, :procedures, :notes
      #:address, :city, :country, :email, :id, :first_name, :last_name, :phone, :procedures, :state, :url, :zip, :notes

      if Surgeon.where(id: u.id).blank?
        Surgeon.new(id: u.id, email: u.Email, first_name: u.SurgeonName.split(',').last, last_name: u.SurgeonName.split(',').first,
                  phone: u.Phone, url: u.URL, procedure_list: u.Procedures, notes: u.Notes,
                  zip: u.ZIP, city: u.City, country: u.Country, address: u.Address ).save(:validate => false)
      end
      bar.inc
    end

    p (surgeons.count - regular_names.count).to_s + " remaining surgeons with weird names to be coverted."
  end
end