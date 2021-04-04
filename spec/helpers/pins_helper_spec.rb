require 'rails_helper'

describe PinsHelper do
	describe '#cover_image' do
		let(:pin_with_images) { create(:pin) }
		it 'returns last pin_image url when that exists' do
      last_image_path = pin_with_images.images.last.url(:medium)
			expect(pin_with_images.cover_image.url(:medium)).to eq(last_image_path)
		end
		it 'returns kitty_url when pin_image url does not exist' do
			allow(pin_with_images).to receive(:images).and_return([])
			expect(pin_with_images.cover_image.url(:medium)).to eq("http://placekitten.com/200/300")
		end
		it 'returns kitty_url when pin_image url does exist but safe_mode is on' do
			expect(pin_with_images.cover_image(true).url(:medium)).to eq("http://placekitten.com/200/300")
		end
	end
end
