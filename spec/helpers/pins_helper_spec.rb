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

	describe '#uses_pronouns' do
		it 'returns they/them/theirs when the author has no gender' do
			expect(uses_pronouns(nil)).to eq("they/them/theirs")
		end

		it 'looks up pronouns by gender name, not id, so a reseeded/renumbered gender still resolves correctly' do
			gender = double(id: 999, name: "FTM")
			expect(uses_pronouns(gender)).to eq("he/him/his")
		end

		it 'returns she/her/hers for MTF regardless of id' do
			gender = double(id: 999, name: "MTF")
			expect(uses_pronouns(gender)).to eq("she/her/hers")
		end

		it 'falls back to they/them/theirs for an unrecognized gender name instead of returning nil' do
			gender = double(id: 999, name: "SomeFutureGender")
			expect(uses_pronouns(gender)).to eq("they/them/theirs")
		end
	end
end
