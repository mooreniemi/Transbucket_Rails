require 'spec_helper'

describe pin_images do
	it "has a valid factory" do
		expect(FactoryGirl.create(:pin_images)).to be_valid
	end
	it "has attached photo" do
		expect(create(:pin_images).should_receive(:photo)) #.and_return(true)
	end
end