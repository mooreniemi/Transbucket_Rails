require 'spec_helper'

describe SearchController do
  it "GET search_terms" do
    get 'search_terms'
    expect(JSON.parse(response.body)).to eq(expected_results)
  end

end

private

def expected_results
  {"suggestions"=>["Double Incision w  nipple grafts", "Periareolar Keyhole", "Double incision w  NO nipple grafts", "T Anchor Double Incision", "FTM Phalloplasty", "Other", "Double Incision w  NO Nipple Grafts", "MTF Bottom Surgery", "FTM Metoidioplasty", "Breast Augmentation Implants", "FFS Facial Feminization Surgery", "Alter  Gary", "Johnson  Melissa", "Bowman  Cameron", "McGinn  Christine", "Lawton  Gary", "Fischer  Beverly", "Garramone  Charles", "Brownstein  Michael", "Medalie  Daniel ", "Protasov  Kirill", "Foley  Art", "Kuzon  William Michael Jr ", "Westburg  Kirsten", "De La Riva  Patricia", "McLean  Hugh", "Johnson  Perry", "Steinwald", "Edwards  Gereth", "Startseva  Olesya", "Leis  Sherman", "Schaarschmidt ", "Tholen  Richard", "Davies  Dai", "other", "Raphael  Peter", "Brassard  Pierre", "Reardon  James J ", "Faridi  Andree", "Andersson  Lena C ", "Monstrey  Stan", "Steinwald  Paul", "Reed  Harold", "Hassall  Megan", "Suporn  Watanyusakul", "Djordjevic  Miroslav", "Daverio  Paul", "Costas  Paul", "Dupere  Marc", "Mangubat  Antonio", "Bowers  Marci", "Perovic  Sava", "Rumer  Kathy", "Bartholomeusz  Hugh", "Menard  Yvon", "Nguyen  Tuan A ", "Weiss  Paul", "Ralph  David", "Meltzer  Toby", "Gilbert  David", "Buckley  Marie Claire", "Van Loenen  Thea", "Caloca  Jaime", "Jones  Justin", "Lincenberg  Sheldon", "Beck  Joel B", "Bartlett  Richard", "Janwialuang  Choomchoke", "Schaff  Jurgen", "Milroy  Catherine", "King  Clifford", "Gahm  Jessica", "Kratz  Gunnar", "Giuffre  Martin", "Crane  Curtis", "Vaniver  Karen", "Liedl  Bernhard", "Yelland  Andrew", "Wilson  Alan Neal", "Vichai Surawongsin"]}
end