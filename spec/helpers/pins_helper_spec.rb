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
		it 'still returns the real image when safe mode is on (the view blurs it instead of swapping it)' do
			last_image_path = pin_with_images.images.last.url(:medium)
			expect(pin_with_images.cover_image(true).url(:medium)).to eq(last_image_path)
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

	describe '#author_pronouns' do
		it 'uses the pronouns the author chose' do
			user = double(pronouns: 'she/they', gender: double(name: 'FTM'))
			expect(author_pronouns(user)).to eq('she/they')
		end

		it 'falls back to the pronouns implied by gender when none were chosen' do
			user = double(pronouns: nil, gender: double(name: 'FTM'))
			expect(author_pronouns(user)).to eq('he/him/his')
		end

		it 'falls back to they/them/theirs for a missing author' do
			expect(author_pronouns(nil)).to eq('they/them/theirs')
		end
	end

	describe '#pronouns_label' do
		it 'shows standard pronouns in the viewer\'s language' do
			I18n.with_locale(:de) do
				expect(pronouns_label('she/her')).to eq('sie/ihr')
				expect(pronouns_label('she/they')).to eq('sie/they')
			end
		end

		it 'keeps the stored value where there is no established equivalent' do
			I18n.with_locale(:de) { expect(pronouns_label('they/them')).to eq('they/them') }
			I18n.with_locale(:tr) { expect(pronouns_label('she/her')).to eq('she/her') }
		end

		it 'never translates what someone typed themselves' do
			I18n.with_locale(:de) { expect(pronouns_label('xe/xem')).to eq('xe/xem') }
			I18n.with_locale(:de) { expect(pronouns_label('er/ihm')).to eq('er/ihm') }
		end

		it 'passes through the gender-derived fallback unchanged' do
			I18n.with_locale(:fr) { expect(pronouns_label('he/him/his')).to eq('he/him/his') }
		end
	end
end
