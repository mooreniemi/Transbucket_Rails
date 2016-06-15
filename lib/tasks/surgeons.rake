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

  desc "remove leading white space from surgeon first name"
  task :white_space_removal => :environment do
    surgeons = Surgeon.all
    surgeons.each do |surgeon|
      if surgeon.first_name.present?
        new_name = surgeon.first_name.gsub(/\A\s/, '')
        surgeon.update_attributes(first_name: new_name) unless new_name.blank?
        surgeon.save
      end
    end
  end

  desc "fix outliers"
  task :outliers => :environment do
    #medalie_pins = Pin.where(surgeon_id: [934, 1012, 956, 954, 947].map(&:to_s))
    medalie_pins = Pin.where(surgeon_id: ['Daniel Medalie'])
    medalie_pins.each {|p| p.surgeon_id = 12; p.save! }

    #mclean_pins = Pin.where(surgeon_id: [960, 1000, 989, 986, 980, 976, 979, 971, 970, 969, 968, 967, 975, 964, 963, 950, 958, 1011].map(&:to_s))
    mclean_pins = Pin.where(surgeon_id: ['Hugh McLean', 'Dr. Hugh Mclean'])
    mclean_pins.each {|p| p.surgeon_id = 31; p.save! }

    mcguinn_pins = Pin.where(surgeon_id: [994, 973, 961, 1003, 974, 1001, 965, 995].map(&:to_s))
    mcguinn_pins.each {|p| p.surgeon_id = 18; p.save! }

    vanloen_pins = Pin.where(surgeon_id: [165, 946, 990].map(&:to_s))
    vanloen_pins.each {|p| p.surgeon.id = 164; p.save!}

    yelland_pins = Pin.where(surgeon_id: [206, 978, 953].map(&:to_s))
    yelland_pins.each {|p| p.surgeon.id = 207; p.save!}

    jj_pins = Pin.where(surgeon_id: 999.to_s)
    jj_pins.each {|p| p.surgeon.id = 170; p.save!}

    morehouse_pins = Pin.where(surgeon_id: 952.to_s)
    morehouse_pins.each {|p| p.surgeon.id = 167; p.save!}

    bowman_pins = Pin.where(surgeon_id: 1009.to_s)
    bowman_pins.each {|p| p.surgeon.id = 94; p.save!}

  end

  desc "fix other"
  task :other => :environment do
    pins = Pin.where(surgeon_id: 'other')
    pins.each {|p| p.surgeon_id = 911; p.save!}
  end

  desc "use seed data"
  task :seed => :environment do
    Surgeon.create!(id: 911) # this surgeon takes the place of any unknown surgeons
    Surgeon.create!([
  {first_name: nil, last_name: "Christiansen", address: nil, city: nil, state: nil, zip: nil, country: nil, phone: nil, email: nil, url: nil, procedure_list: nil, notes: nil},
  {first_name: nil, last_name: "Cartwright", address: nil, city: nil, state: nil, zip: nil, country: nil, phone: nil, email: nil, url: nil, procedure_list: nil, notes: nil},
  {first_name: "Melissa", last_name: "Johnson", address: "100  Wason Ave.  Suite 360  (Pioneer Valley Plastic Surgery)", city: "Springfield", state: nil, zip: 1107, country: "USA", phone: 413, email: nil, url: "www.pvps.net", procedure_list: "Double Incision, Periareolar", notes: "We received confirmation from Dr. Johnson's office that she does provide a letter to patients after completion of their surgery.  "},
  {first_name: "Jed", last_name: "Horowitz", address: "7677 Center Ave Suite 401", city: "Huntington Beach", state: nil, zip: 92647, country: "USA", phone: 714, email: "plasticosfoundation@yahoo.com", url: "http://pacificcenterplasticsurgery.com/horowitz.htm", procedure_list: "Breast augmentation, FFS, Gynecomastia", notes: nil},
  {first_name: "Sherman", last_name: "Leis", address: "19 Montgomery Ave", city: "Bala Cynwyd", state: nil, zip: 19004, country: "USA", phone: 610, email: "drshermanleis@drshermanleis.com", url: "http://www.thetransgendercenter.com", procedure_list: "Vaginoplasty, Breast Augmentation, Hair Removal, FFS (see website), Double Incision, Periareolar, Phalloplasty, Scrotoplasty", notes: nil},
  {first_name: "James", last_name: "Dalrymple", address: "36 Weymouth St", city: "London", state: nil, zip: nil, country: "United Kingdom", phone: 44, email: "info@lbh.hcahealthcare.co.uk", url: nil, procedure_list: "Vaginoplasty", notes: nil},
  {first_name: nil, last_name: "other", address: nil, city: nil, state: nil, zip: nil, country: nil, phone: nil, email: nil, url: nil, procedure_list: nil, notes: nil},
  {first_name: "Paul", last_name: "Sedacca", address: "2300 South Broad Street", city: "Philadelphia", state: nil, zip: 19145, country: "USA", phone: 866, email: nil, url: nil, procedure_list: "Laser Hair Removal", notes: nil},
  {first_name: "Beverly", last_name: "Fischer", address: "12205 Tullamore Rd", city: "Timonium", state: nil, zip: 21093, country: "USA", phone: 410, email: "beverly@beverlyfischer.com ", url: "http://www.beverlyfischer.com/", procedure_list: "Double Incision, Periareolar", notes: nil},
  {first_name: "Peter", last_name: "Raphael", address: "1600 Coit St 105", city: "Plano", state: nil, zip: 75075, country: "USA", phone: 972, email: nil, url: nil, procedure_list: "Metoidioplasty, Double Incision, Periareolar, FFS (see Website), Breast Augmentation, Orchiectomy, ", notes: nil},
  {first_name: "Charles", last_name: "Garramone", address: "12651 W. Sunrise Blvd., Suite 102", city: "Sunrise", state: nil, zip: 33325, country: "USA", phone: 954, email: nil, url: "http://www.transgenderflorida.com", procedure_list: "Double Incision, Periareolar, Breast enhancement, Breast reduction, Facelift, Rhinoplasty, Forehead Lift, Eyelid Surgery", notes: nil},
  {first_name: "Toby", last_name: "Meltzer", address: "7025 N Scottsdale Rd Suite 302", city: "Scottsdale", state: nil, zip: 85352, country: "USA", phone: 480, email: nil, url: "http://www.tmeltzer.com", procedure_list: "Vaginoplasty, Phalloplasty, Labiaplasty, Breast Augmentation, FFS (see website), Metoidioplasty, Double Incision, Periareolar", notes: nil},
  {first_name: "Daniel ", last_name: "Medalie", address: "2500 MetroHealth Drive", city: "Cleveland", state: nil, zip: 44109, country: "USA", phone: 216, email: "info@clevelandplasticsurgery.com", url: "http://www.clevelandplasticsurgery.com", procedure_list: "MtF and FtM top surgery, facial feminization with bone contouring and soft tissue augmentation, body contouring and labiaplasty.", notes: nil},
  {first_name: "Gary", last_name: "Lawton", address: "525 Oak Centre Drive Suite 260", city: "San Antonio", state: nil, zip: 78258, country: "USA", phone: 210, email: "gpl@plasticsurgery-sanantonio.com", url: "http://www.plasticsurgery-sanantonio.com/index.html", procedure_list: "Double Incision, Breast Augmentation, Laser Skin Resurfacing, Laser Hair Removal", notes: nil},
  {first_name: "Yvon", last_name: "Menard", address: "1003 East Boulevard", city: "St. Joseph, Montreal", state: nil, zip: nil, country: "Canada", phone: 514, email: "info@grsmontreal.com", url: "http://www.grsmontreal.com", procedure_list: "Phalloplasty, Metoidioplasty, Clitoral Freeing, Double Incision", notes: nil},
  {first_name: "Jenelle", last_name: "Foote", address: "128 North Avenue Suite 100", city: "Atlanta", state: nil, zip: 30308, country: "USA", phone: 404, email: nil, url: nil, procedure_list: "Orchiectomy", notes: nil},
  {first_name: "Christine", last_name: "McGinn", address: "18 Village Row, Suite 43 Logan Square Lower York Road (202)", city: "New Hope, PA ", state: nil, zip: 18938, country: "USA", phone: 0, email: "papilloncenter@aol.com", url: "http://www.drchristinemcginn.com", procedure_list: "Vaginoplasty, Labiaplsty, FTM top surgeries, Metoidioplasty with or without urethroplasty, Scrotoplasty, FFS, Breast Augmentation, Trachea Shave, Permanent Hair Removal, Voice Therapy, Counseling and Hormone therapy.", notes: nil},
  {first_name: "Harold", last_name: "Reed", address: "111 Kane Concourse Suite 311", city: "Bay Harbor Islands", state: nil, zip: 33154, country: "USA", phone: 305, email: nil, url: "http://www.srsmiami.com", procedure_list: "Vaginoplasty, Orchiectomy", notes: nil},
  {first_name: "Timothy", last_name: "Terry", address: "Leicester General Hospital, Gwendolen Rd", city: "Leicester", state: nil, zip: nil, country: "United Kingdom", phone: 116, email: "GRSTerry@aol.com", url: "http://www.nuffieldhospitals.co.uk", procedure_list: "Orchiectomy, Vaginoplasty", notes: nil},
  {first_name: "Bhumsak", last_name: "Saksri", address: "199/4 Sammakorn Housing Estate", city: "Bangkok", state: nil, zip: nil, country: "Thailand", phone: nil, email: "info@thailandplasticsurgery.com", url: "http://neopsc.com/", procedure_list: "Vaginoplasty", notes: nil},
  {first_name: "Chettawut", last_name: "Tulayaphanich", address: "Vibhavadi II Hospital, 1529/4 Onnut 31 Sukumvit 77 Rd.", city: "Bangkok", state: nil, zip: nil, country: "Thailand", phone: nil, email: "info@chet-plasticsurgery.com", url: "http://www.chet-plasticsurgery.com", procedure_list: "FTM Top Surgery, MTF Top Surgery, MTF Bottom Surgery, Facial Surgery", notes: "Competitively priced, friendly staff and great after care"},
  {first_name: "Choomchoke", last_name: "Janwialuang", address: "Box 109, Nathon Post Office, Koh Samui", city: "Surat Thani", state: nil, zip: nil, country: "Thailand", phone: 66, email: "info@sexchangeasia.com", url: "http://www.srsthailand.com", procedure_list: "Orchiectomy, Vaginoplasty", notes: nil},
  {first_name: "Paul", last_name: "Daverio", address: "Helena-Lange-Strasse 13 14469", city: "Potsdam", state: nil, zip: nil, country: "Germany", phone: 331, email: "info@kliniksanssouci.de", url: "http://www.kliniksanssouci.de/english/index_new.htm", procedure_list: "Vaginoplasty", notes: nil},
  {first_name: "Hugh", last_name: "McLean", address: "50 Burnhamthorpe Road West Suite 343", city: "Mississauga, Ontario", state: nil, zip: nil, country: "Canada", phone: 905, email: "info@mcleanclinic.com", url: "http://www.mcleanclinic.com", procedure_list: "Double Incision, Periareolar, Breast Augmentation, Laser Hair Removal, Facelift, Eyelids, Rhinoplasty", notes: nil},
  {first_name: "Andree", last_name: "Faridi", address: "Rubenkamp 220", city: "Hamburg", state: nil, zip: nil, country: "Germany", phone: 49, email: "a.faridi@asklepios.com", url: "http://www.asklepios.com/barmbek/html/fachabt/gyn/index.asp", procedure_list: "FTM Top", notes: nil},
  {first_name: "Pornsinsirirak", last_name: "Greechart", address: "454 Charunsanitwong Road (Soi 90) Bang-O Bangpad ", city: "Bangkok", state: nil, zip: nil, country: "Thailand", phone: 66, email: "greechartp@yahoo.com", url: "http://www.yanhee.net/serv_sexreass.htm", procedure_list: "Vaginoplasty", notes: nil},
  {first_name: "Cameron", last_name: "Bowman", address: nil, city: nil, state: nil, zip: nil, country: nil, phone: nil, email: nil, url: nil, procedure_list: nil, notes: nil},
  {first_name: "Ben", last_name: "Childers", address: "4605 Brockton Ave # 200  ", city: "Riverside", state: nil, zip: 92506, country: "USA", phone: 0, email: nil, url: nil, procedure_list: "FTM Top", notes: "Update as of May 2012: Dr. Childers is now providing letters."},
  {first_name: "James", last_name: "Bellringer", address: "162 Cromwell Rd", city: "London", state: nil, zip: nil, country: "United Kingdom", phone: 44, email: "jbellringer@genderxchange.co.uk", url: "http://genderxchange.co.uk/", procedure_list: "Vaginoplasty", notes: nil},
  {first_name: "Marci", last_name: "Bowers", address: "328 Bonaventure St Suite 2", city: "Trinidad", state: nil, zip: 81082, country: "USA", phone: 719, email: "info@marcibowers.com", url: "http://marcibowers.com", procedure_list: "MTF: Vaginoplasty, Breast Augmentation, Tracheal Shave, Labiaplasty FTM: Simple Metoidioplasty, Ring Metoidoiplasty (Meta with Urethral Lengthening), Hysterectomy, and Testicle Implants", notes: nil},
  {first_name: "Pierre", last_name: "Brassard", address: "1003 East St-Joseph Blvd", city: "Montreal (Quebec)", state: nil, zip: nil, country: "Canada", phone: 514, email: "info@grsmontreal.com", url: "http://www.grsmontreal.com", procedure_list: "Vaginoplasty", notes: nil},
  {first_name: "Peter", last_name: "Haertsch", address: "Suite 209 2 Pembrooke S. Epping", city: "New South Wales", state: nil, zip: nil, country: "Australia", phone: 0, email: "peterhaertsch@bigpond.com.au", url: "http://www.haertsch.com.au/", procedure_list: "Vaginoplasty", notes: nil},
  {first_name: "Paul", last_name: "Costas", address: "John Cuming Building, Suite 700", city: "Concord", state: nil, zip: 1742, country: "USA", phone: 1, email: nil, url: nil, procedure_list: "Periareolar, Double Incision", notes: nil},
  {first_name: "Sava", last_name: "Perovic", address: "Tirsova 10", city: "Belgrade", state: nil, zip: nil, country: "Serbia", phone: nil, email: "consult@savaperovic.com", url: "http://www.savaperovic.com/", procedure_list: "Metoidioplasty, Phalloplasty", notes: nil},
  {first_name: "David", last_name: "Gilbert", address: "400 West Brambleton Ave Suite 300", city: "Norfolk", state: nil, zip: 23510, country: "USA", phone: 800, email: nil, url: nil, procedure_list: "Phalloplasty", notes: nil},
  {first_name: "Hope", last_name: "Sherie", address: nil, city: nil, state: nil, zip: nil, country: nil, phone: nil, email: nil, url: "", procedure_list: nil, notes: nil},
  {first_name: "RH", last_name: "Fang", address: "Veterans General Hospital, No. 201, Sec. 2, Shih-Pai Road", city: "Taipei", state: nil, zip: nil, country: "Taiwan", phone: 886, email: "lychang@vghtpe.gov.tw", url: "http://www.vghtpe.gov.tw/doce/", procedure_list: "Vaginoplasty", notes: nil},
  {first_name: "Navin", last_name: "Singh", address: nil, city: "Washington, DC", state: "Maryland", zip: nil, country: "US", phone: nil, email: nil, url: "http://www.ivyplasticsurgery.com/meet-the-doctors/dr-navin-singh/", procedure_list: nil, notes: nil},
  {first_name: "Daniel", last_name: "Greenwald", address: "505 South Boulevard Ave", city: "Tampa", state: nil, zip: 33606, country: "USA", phone: 1, email: nil, url: nil, procedure_list: "Chest surgery, Metaoidioplasty, Urethraplasty, Scrotoplasty, Vaginectomy, Phalloplasty", notes: nil},
  {first_name: "Patrick", last_name: "Hudson", address: "1101 Medical Arts NE #3", city: "Albuquerque", state: nil, zip: 87102, country: "USA", phone: 505, email: "doctor@phudson.com", url: "http://www.phudson.com", procedure_list: "Breast augmentation, Labiaplasty, Facelift, Eyelids, Rhinoplasty", notes: nil},
  {first_name: "Perry", last_name: "Johnson", address: "2727 South 144th St. Suite 255", city: "Omaha", state: nil, zip: 68144, country: "USA", phone: 866, email: "info@surgicaldreams.com", url: "http://www.surgicaldreams.com", procedure_list: "Double Incision, Breast Augmentation, Rhinoplasty, Facelift, Eyelid, Forehead", notes: nil},
  {first_name: "Joseph", last_name: "Rosen", address: "One Medical Center Drive", city: "Lebanon", state: nil, zip: 3756, country: "USA", phone: 603, email: nil, url: "http://www.dhmc.org", procedure_list: "Chest surgery, Metaoidioplasty ", notes: nil},
  {first_name: "Michael", last_name: "Stephanides", address: "2201 Murphy Ave #401", city: "Nashville", state: nil, zip: 37203, country: "USA", phone: 615, email: nil, url: "http://www.orcuttplasticsurgery.com", procedure_list: "Reduction mammoplasty, Phalloplasty", notes: nil},
  {first_name: "Miroslav", last_name: "Djordjevic", address: nil, city: "Belgrade", state: nil, zip: nil, country: "Serbia", phone: nil, email: "metoidioplasty@gmail.com", url: "http://www.metoidioplasty.com/", procedure_list: "Metoidioplasty", notes: nil},
  {first_name: "Azid", last_name: "Hashmat", address: "555 Prospect St", city: "Brooklyn", state: nil, zip: 11238, country: "USA", phone: 718, email: nil, url: nil, procedure_list: "Vaginoplasty", notes: nil},
  {first_name: "Ted", last_name: "Huang", address: "326 Market St", city: "Galveston", state: nil, zip: 77550, country: "USA", phone: 409, email: nil, url: nil, procedure_list: "Vaginoplasty", notes: nil},
  {first_name: "Jirapong", last_name: "Poony", address: "Soi 4 Pattaya 2nd Rd", city: "Pattaya City Cholburi", state: nil, zip: nil, country: "Thailand", phone: 38, email: "picpih@ptty.loxinfo.co.th", url: "http://www.pattaya-inter-hospital.co.th", procedure_list: "Vaginoplasty", notes: nil},
  {first_name: "Kamol", last_name: "Pansritum", address: "668/128 Laksi Square", city: "Anusawaree Laksi, Bangkane, Bangkok", state: nil, zip: nil, country: "Thailand", phone: 662, email: "info@mtfsurgery.com", url: "http://www.mtfsurgery.com/main.html", procedure_list: "Vaginoplasty", notes: nil},
  {first_name: "John", last_name: "Kenney", address: "914 E Jefferson St #202", city: "Charlottesville", state: nil, zip: 22902, country: "USA", phone: 434, email: nil, url: nil, procedure_list: "Vaginoplasty", notes: nil},
  {first_name: "Michael", last_name: "Krueger", address: "Helena-Lange-Strasse 13", city: "Potsdam", state: nil, zip: nil, country: "Germany", phone: 331, email: "info@kliniksanssouci.de", url: "http://www.kliniksanssouci.de/english/index_new.htm", procedure_list: "Vaginoplasty", notes: nil},
  {first_name: "Donald", last_name: "Laub", address: "183 Talcott Rd Suite 206", city: "Williston", state: nil, zip: 5495, country: "USA", phone: 802, email: "wbnphd@aol.com", url: nil, procedure_list: "Vaginoplasty", notes: nil},
  {first_name: "Sun-Kyu", last_name: "Lee", address: "3rd Floor, 1-3 Rex Tower Bldg., Nonhyun-dong", city: "Kangnam-gu, Seoul", state: nil, zip: nil, country: "Korea", phone: 833, email: "master@urotop.co.kr", url: "http://www.urotop.co.kr/en/specialty_n.htm", procedure_list: "Vaginoplasty, Voice Surgery, Tracheal Shave, Breast Augmentation", notes: nil},
  {first_name: "Pablo", last_name: "Maldonado", address: "CEM Rocha St. 60 number 558", city: "La Plata, Buenos Aires", state: nil, zip: nil, country: "Argentina", phone: 54, email: "cirugiaplastica@dr-pablomaldonado.com.ar", url: "http://www.dr-pablomaldonado.com.ar/iprincipal.htm", procedure_list: "Vaginoplasty", notes: nil},
  {first_name: "Ernest", last_name: "Manders", address: "3550 Terrace St. 666 Scaife Hall", city: "Pittsburgh", state: nil, zip: 15261, country: "USA", phone: 412, email: "mandersek@msx.upmc.edu", url: nil, procedure_list: "Vaginoplasty", notes: nil},
  {first_name: "Nara", last_name: "Donaskul", address: "112 Thamanoonvithi Rd", city: "Hatyai, Songkhla", state: nil, zip: nil, country: "Thailand", phone: 66, email: "nara@dr-nara.com", url: "http://www.dr-nara.com/", procedure_list: "Vaginoplasty", notes: nil},
  {first_name: "Narongdet", last_name: "Jiarapipan", address: "59/7 Moo 10 Rama 2 Rd", city: "Bangmod Sub-district, Jomthong District,", state: nil, zip: nil, country: "Thailand", phone: 0, email: "bangmod@bangmodhos.com", url: "http://www.bangmodhos.com/english/beauty/sex.html", procedure_list: "Vaginoplasty", notes: nil},
  {first_name: "Michael", last_name: "Royle", address: "55 New Church Road", city: "Hove, East Sussex", state: nil, zip: nil, country: "United Kingdom", phone: 127, email: nil, url: "http://www.nuffieldhospitals.org.uk/pages/hospitals/sussex/home.htm", procedure_list: "Vaginoplasty", notes: nil},
  {first_name: "Ruch", last_name: "Wongtrungkapon", address: "2138 Ramkhamhaeng Rd", city: "Huamark, Bangkapi, Bangkok", state: nil, zip: nil, country: "Thailand", phone: 662, email: "the_docbangkok@yahoo.com", url: "http://www.ramhospital.com/GenderDisorderClinic.htm", procedure_list: "Vaginoplasty", notes: nil},
  {first_name: "Sanguan", last_name: "Kunaporn", address: "20/44 Mae Luan Road", city: "Phukett", state: nil, zip: nil, country: "Thailand", phone: 66, email: "info@phuket-plasticsurgery.com", url: "http://www.phuket-plasticsurgery.com/", procedure_list: "Vaginoplasty", notes: nil},
  {first_name: "Kunachakr", last_name: "Somsak", address: "950 Prachachuen Rd", city: "Bangsae, Bangkok", state: nil, zip: nil, country: "Thailand", phone: 66, email: "kasemrad@kasemrad.net", url: "http://www.kasemrad.net/", procedure_list: "Vaginoplasty", notes: nil},
  {first_name: "Watanyusakul", last_name: "Suporn", address: "939 Sukhumvit Rd.", city: "Bangplasoi, Chonburi", state: nil, zip: nil, country: "Thailand", phone: nil, email: "admin@supornclinic.com", url: "http://www.supornclinic.com", procedure_list: "Vaginoplasty", notes: nil},
  {first_name: "Philip", last_name: "Thomas", address: "Warren Rd.", city: "Woodingdean, Brighton, Sussex", state: nil, zip: nil, country: "United Kingdom", phone: 1273, email: nil, url: nil, procedure_list: "Vaginoplasty", notes: nil},
  {first_name: "Vesely", last_name: "Jiri", address: "Berkova 34/38", city: nil, state: nil, zip: nil, country: "Brno", phone: 541, email: "jiri.vesely@fnusa.cz ", url: "http://www.muni.cz/to.cs/med/structure/110100.html", procedure_list: "Vaginoplasty", notes: nil},
  {first_name: "Wisuthseriwong", last_name: "Witoon", address: "Clinic Soi 1, 220/2-3 Sukhumwit, Soi 1", city: "Bangkok", state: nil, zip: nil, country: "Thailand", phone: 66, email: "consult@witoon.com", url: "http://www.witoon.com/eindex.htm", procedure_list: "Vaginoplasty", notes: nil},
  {first_name: "Sheldon", last_name: "Lincenberg", address: "One Glenlake Parkway, Suite 950 ", city: "Atlanta", state: nil, zip: 30328, country: "United States", phone: 0, email: nil, url: "http://www.gaplasticsurg.com/index.html", procedure_list: "FTM Top", notes: nil},
  {first_name: "Kirill", last_name: "Protasov", address: "Staropetergofsky Ave, 12, 190020", city: "St. Petersburg", state: nil, zip: nil, country: "Russia", phone: 7, email: "protasov_kirill@list.ru", url: "http://protasov.com", procedure_list: "Mastectomy (double incision, keyhole,  peri-areolar), Facelifts, Rhinoplasty, Eyelid surgery, Laser  resurfacing, Lip enlargement, Breast Enhancement, Breast reduction,  Liposuction, Labiaplasty, Clitoral freeing. ", notes: nil},
  {first_name: "Antonio", last_name: "Mangubat", address: "16400 Southcenter Pkwy Suite 101", city: "Seattle", state: nil, zip: 98188, country: "United States", phone: 206, email: nil, url: "http://www.southcentercosmetic.com/ ", procedure_list: "Breast Implants/Augmentation, FTM Top Surgery, Laser Hair Removal, Skin Resurfacing, Rhinoplasty (Nose Surgery), Blepharoplasty (Eyelid Surgery), Face Lift, Brow Lift, Cheek Implants, Chin Implant , Ear Surgery, Laser Resurfacing", notes: nil},
  {first_name: "CF", last_name: "Chen", address: "Veterans General Hospital, No. 201, Sec. 2, Shih-Pai Road", city: "Taipei", state: nil, zip: nil, country: "Taiwan", phone: 886, email: "lychang@vghtpe.gov.tw", url: "http://www.vghtpe.gov.tw/doce/", procedure_list: "Vaginoplasty", notes: nil},
  {first_name: "Marvin", last_name: "Corman", address: "1450 San Pablo St Suite 5400", city: "Los Angeles", state: nil, zip: 90033, country: "USA", phone: 323, email: "mcorman@surgery.hsc.usc.edu", url: "http://www.surgery.usc.edu/divisions/cr/cv-corman.html", procedure_list: "Vaginoplasty, Fistula Repair", notes: nil},
  {first_name: "Megan", last_name: "Hassall", address: "Suite 11, 66 Pacific Hwy", city: "St Leonards, New South Wales", state: nil, zip: 2065, country: "Australia", phone: 0, email: nil, url: nil, procedure_list: "Does FTM top surgery", notes: nil},
  {first_name: "Sonia", last_name: "Grover", address: "Suite 6, 214 Burgundy Street", city: "Heidelberg, Victoria", state: nil, zip: 3084, country: "Australia", phone: 3, email: nil, url: nil, procedure_list: "FTM Hysterectomies. ", notes: nil},
  {first_name: "Dai", last_name: "Davies", address: "55 Harley Street ", city: "London", state: nil, zip: nil, country: "United Kingdom", phone: 800, email: "enquiries@plasticsurgerypartners.co.uk", url: "http://www.daidavies.org/index.html", procedure_list: "FTM Top", notes: nil},
  {first_name: "David", last_name: "Ralph", address: "UCH London", city: "London", state: nil, zip: nil, country: "United Kingdom", phone: 845, email: nil, url: "http://www.uclh.nhs.uk/GPs+healthcare+professionals/Consultants/D.+Ralph.htm", procedure_list: "FTM Bottom", notes: "Operates on NHS"},
  {first_name: "Dmitry", last_name: "Krasnojon", address: "", city: "St. Petersburg", state: nil, zip: nil, country: "Russia", phone: nil, email: nil, url: nil, procedure_list: "FTM Top", notes: nil},
  {first_name: "Paul", last_name: "Steinwald", address: "700A North Westmoreland Road", city: "Lake Forest", state: nil, zip: 60045, country: "United States", phone: 847, email: nil, url: "http://www.lfplasticsurgery.com/index.pl/ftm_chest_masculinization", procedure_list: "FTM Top", notes: nil},
  {first_name: "Kathy", last_name: "Rumer", address: "105 Ardmore Avenue", city: "Ardmore", state: nil, zip: 19003, country: "United States", phone: 484, email: nil, url: "http://www.RumerCosmetics.com", procedure_list: "Vaginoplasty, Labiaplsty, FTM & MTF top surgeries, Metoidioplasty with or without urethroplasty,  FFS, Double Incision, Periareolar, Phalloplasty, Scrotoplasty, FFS, Breast Augmentation, Trachea Shave, Permanent Hair Removal, Counseling and Hormone therapy", notes: "Note from Dr. Rumer: We offer patient recovery apartments above my practice for overnight or extended stays during recovery."},
  {first_name: "Paul", last_name: "Weiss", address: "1049 5th Ave, Suite 2D", city: "New York", state: nil, zip: 10028, country: "United States", phone: 212, email: nil, url: "http://www.drpaulweiss.com/", procedure_list: "FTM Top Surgery, MTF Top Surgery, Facial Surgery", notes: nil},
  {first_name: "Kirsten", last_name: "Westburg", address: nil, city: "Red Deer", state: nil, zip: nil, country: "Canada", phone: 1, email: nil, url: nil, procedure_list: "FTM Top Surgery", notes: "Works in conjunction with Alberta Health Care to provide surgery. Provides many other kinds of plastic and reconstructive surgery, and as such only takes referrals every so often as she refuses to book more then a year in advance for patient care reasons. "},
  {first_name: "Marc", last_name: "Dupere", address: "179 John Street, Suite 209", city: "Toronto", state: nil, zip: nil, country: "Canada", phone: 416, email: nil, url: "www.visageclinic.ca", procedure_list: "FTM Top", notes: nil},
  {first_name: "David", last_name: "Musto", address: nil, city: "Abbotsford", state: nil, zip: nil, country: "Canada", phone: 604, email: "davidmusto@telus.net ", url: "http://www.southfrasersurgical.com/musto.html", procedure_list: "FTM Top Surgery", notes: nil},
  {first_name: "Stan", last_name: "Monstrey", address: "Universitair Ziekenhuis Gent Kliniek voor Plastische Heelkunde De Pintelaan ", city: nil, state: nil, zip: nil, country: "Belgium", phone: nil, email: "jan.smeyers@uzgent.be", url: nil, procedure_list: "FTM Top Surgery, FTM Bottom Surgery, MTF Top Surgery, MTF Bottom Surgery", notes: "Prof. Monstrey works with the urologist Prof. Piet Hoebeke for all lower surgery procedures."},
  {first_name: "Olesya", last_name: "Startseva", address: "Abrikosovskyi per. 2,", city: nil, state: nil, zip: nil, country: "Russia", phone: 7, email: nil, url: nil, procedure_list: "FTM Top Surgery, FTM Bottom Surgery", notes: nil},
  {first_name: "Richard", last_name: "Tholen", address: "4825 Olson Memorial Highway (Hwy 55) Suite 200", city: "Minneapolis", state: nil, zip: nil, country: "United States", phone: 0, email: nil, url: "http://www.mpsmn.com", procedure_list: "FTM Top Surgery, MTF Top Surgery, Facial Surgery", notes: "He no longer accepts insurance. However, his cost includes all follow up appointments and revisions if needed. He also has cosmetic tattooing in cases where tattooing is necessary (aerolas etc). His partner is Dr. Douglas Gervais who also does FTM top surgery."},
  {first_name: "Lois", last_name: "Wagstrom", address: nil, city: "Nashville", state: nil, zip: nil, country: "United States", phone: 615, email: nil, url: nil, procedure_list: "MTF Top", notes: nil},
  {first_name: "Peter", last_name: "Davis", address: "1515 El Camino Real, Suite D", city: "Palo Alto", state: nil, zip: 94306, country: "United States", phone: 650, email: "PKDavisMD@me.com", url: "http://www.DavisPlasticSurgery.com", procedure_list: "FTM Top Surgery, MTF Top Surgery, MTF Bottom Surgery, Facial Surgery, Facial & Body Feminization", notes: "Procedures Performed: Vaginoplasty, Labiaplasty, Facial and Body Feminization, Breast Augmentation, FtM Top Surgery. WPATH member"},
  {first_name: "Constance", last_name: "Ling", address: "152 Cleopatra Drive Suite 305", city: "Ottawa", state: nil, zip: nil, country: "Canada", phone: nil, email: nil, url: nil, procedure_list: "Hystorectomy, Oophrectomy", notes: "Need referral from treating doctor and psychologist. No outside appointments taken."},
  {first_name: "Fredrik", last_name: "Huss", address: "Hand- och plastikkirurgen, Universitetssjukhuset Linköping       ", city: nil, state: nil, zip: nil, country: "Sweden", phone: nil, email: nil, url: nil, procedure_list: "FTM Top Surgery, FTM Bottom Surgery, MTF Bottom Surgery", notes: nil},
  {first_name: "Gunnar", last_name: "Kratz", address: "Hand- och plastikkirurgen Linköping ", city: nil, state: nil, zip: nil, country: "Sweden", phone: nil, email: nil, url: nil, procedure_list: "FTM Top Surgery, FTM Bottom Surgery, MTF Bottom Surgery", notes: nil},
  {first_name: "Jeffrey", last_name: "Schreiber", address: "10807 Falls Road Suite 101", city: "Lutherville", state: nil, zip: nil, country: "United States", phone: 410, email: "doctor@drschreiberplasticsurgery.com", url: "http://www.drschreiberplasticsurgery.com/", procedure_list: "FTM Top, MtF top surgery, facial surgery, and hair removal.", notes: nil},
  {first_name: "Art", last_name: "Foley", address: nil, city: "Olympia", state: nil, zip: nil, country: "United States", phone: 1, email: nil, url: "http://drfoley.com", procedure_list: "FTM Top Surgery, MTF Top Surgery, Facial Surgery, Laser Hair Removal", notes: "Gives you a detailed outline of the surgery and sketches the incision lines onto a picture of you during the actual consultation.  Eliminates visible dog ears by extending the incision to under the armpit.  $50 consult fee, applies to surgery if you want, or to skin care products."},
  {first_name: "Teresita", last_name: "Mascardo", address: "120 EAST 61st Street", city: "New York", state: nil, zip: 10021, country: "United States", phone: 212, email: nil, url: " http://www.teresitamascardomd.com", procedure_list: "FTM Top Surgery, MTF Top Surgery, Facial Surgery, Liposuction", notes: "Dr. Mascardo also has an office in CT http://www.teresitamascardomd.com  In Connecticut,  located at  598 Danbury Rd. Rigefield, CT 06877;  Telephone Number is 203 431-0280"},
  {first_name: "Jeffrey", last_name: "Spiegel", address: "830 Harrison Avenue, Suite 1400", city: "Boston", state: nil, zip: nil, country: "United States", phone: 617, email: "ivy.solis@bmc.org", url: "http://www.jeffreyspiegel.vpweb.com/", procedure_list: "FFS", notes: "Dr. Spiegel can visit with you using Skype or Ichat.  Contact via email/phone to set up a time to meet with Dr. Spiegel on the web!"},
  {first_name: "Jonathan", last_name: "Graff", address: nil, city: "Buffalo", state: nil, zip: nil, country: "", phone: 716, email: "info@centerplasticsurg.com", url: "http://www.centerplasticsurg.com/", procedure_list: "MTF Top, FTM Top", notes: nil},
  {first_name: "Ran", last_name: "Talisman", address: "Zeitlin St. 1, 4th Floor", city: nil, state: nil, zip: nil, country: "Israel", phone: 0, email: "info@dr-t.co.il", url: "www.dr-t.co.il", procedure_list: "FTM Top, Facial Surgery", notes: nil},
  {first_name: "Raad", last_name: "Taki", address: "4580 East Camp Lowell Drive", city: "Tucson", state: nil, zip: 85712, country: "United States", phone: 520, email: nil, url: "http://www.takiplasticsurgery.com/", procedure_list: "FTM Top Surgery", notes: nil},
  {first_name: "Benoit", last_name: "Coustal", address: "Clinique Croix st Michel 40 avenue Charle de Gaulle", city: "Montauban", state: nil, zip: 82000, country: "France", phone: 5, email: "benoit.coustal@wanadoo.fr", url: "http://www.esthetique-montauban.com", procedure_list: "FTM Top", notes: "Very cheap and good surgeon. Does both double incision and peri methods. Surgery is 2000 - 3000 euros"},
  {first_name: "Hugh", last_name: "Bartholomeusz", address: "Greenslopes Private Hospital Newdegate Street", city: "Greenslopes, Queensland", state: nil, zip: 4120, country: "Australia", phone: 7, email: "info@greenslopesplasticsurgery.com.au", url: "http://greenslopesplasticsurgery.com.au", procedure_list: "Does FTM top surgery", notes: nil},
  {first_name: "Howard", last_name: "Silverman", address: "1525 Carling Avenue Suite 502", city: "Ottawa", state: nil, zip: nil, country: "Canada", phone: 613, email: nil, url: "http://www.ottawaplasticsurgery.com/", procedure_list: "FTM Top Surgery", notes: "Requires therapist letter for performing top surgery"},
  {first_name: "Robert", last_name: "Kampmann", address: nil, city: "Cologne", state: nil, zip: nil, country: "Germany", phone: nil, email: "dr.robert.kampmann@josef-hospital.de", url: "http://www.josef-hospital.de/", procedure_list: "FTM Top Surgery", notes: "This surgeon has done many mastectomy on ftm's. Double incision and key hole. He is experienced and very good value for money"},
  {first_name: "Deborah", last_name: "Sillins", address: "3005 Dixie Highway Suite 240 Edgewood", city: "Florence", state: nil, zip: 41017, country: "USA", phone: 859, email: nil, url: "http://www.deborahsillinsmd.com/", procedure_list: "FTM Top Surgery, Laser Hair Removal", notes: "Her practice is called a Womans Touch but she is very understanding of the FTM transexual. Her and her staff were all so very kind through out the whole thing. Provides letters for gender marker change."}
])
  end
end
