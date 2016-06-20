namespace :addresses do
  desc "wherever we have a zipcode but lack other address info, fill it in"
  task :populate => :environment do
    require 'zip-codes'
    require 'rake-progressbar'


    surgeons_w_zips = Surgeon.where.not(zip: nil)
    bar = RakeProgressbar.new(surgeons_w_zips.count)

    surgeons_w_zips.find_each do |surgeon|
      # zipcodes were stored as integers at one point
      # which cut off leading zeroes we need
      zipcode = surgeon.zip.rjust(5, '0')
      address = ZipCodes.identify(zipcode)

      next if address.nil?
      bar.inc
      surgeon.update_attributes!(
        state: address[:state_code],
        city: address[:city],
        zip: zipcode
      )
    end
  end
end
