#spec/models/pin_spec.rb
require 'spec_helper'

describe Pin do
	it "has a valid factory" do
		expect(FactoryGirl.create(:pin)).to be_valid
	end
	it "is invalid without a surgeon" do
		expect(FactoryGirl.build(:pin, surgeon: nil)).to_not be_valid
	end
	it "is invalid without a user_id" do
		expect(FactoryGirl.build(:pin, user_id: nil)).to_not be_valid
	end
	it "is invalid without a procedure" do
		expect(FactoryGirl.build(:pin, procedure: nil)).to_not be_valid
	end
	#it "has valid pin_images" do
	#	FactoryGirl.create(:pin).should_receive(:pin_images) #.and_return(true)
	#end
end