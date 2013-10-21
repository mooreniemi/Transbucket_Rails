require 'spec_helper'

describe PinImage do
	it "has a valid factory" do
		expect(FactoryGirl.create(:pin_images)).to be_valid
	end
	it "has attached photo" do
		expect(FactoryGirl.create(:pin_images).should_receive(:photo)) #.and_return(true)
	end
end