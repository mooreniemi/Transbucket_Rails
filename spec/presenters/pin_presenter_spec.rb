require 'rails_helper'

describe PinPresenter do
  before(:each) do
    Rails.cache.clear
  end

  let!(:pins) { create_list(:pin, 3) }

  describe '#list_event_context' do
    it 'identifies the unfiltered default feed without query text or filter values' do
      presenter = PinPresenter.new(current_user: create(:user))

      expect(presenter.list_event_context).to eq(
        surface: 'pins_index', list_mode: 'recent', filter_signature: '', ranking_version: 'recent_submission_activity_v1'
      )
    end

    it 'identifies the actual filtered list shape without retaining filter values' do
      procedure = create(:procedure)
      presenter = PinPresenter.new(current_user: create(:user), procedure: [procedure.id], satisfaction: '5')

      expect(presenter.list_event_context).to eq(
        surface: 'pins_index', list_mode: 'filtered', filter_signature: 'procedure,satisfaction', ranking_version: 'filtered_recent_activity_v1'
      )
    end
  end

  it 'returns pins' do
    expect(PinPresenter.new.pins).to eq(pins.to_a.reverse)
  end

  describe 'personalized feeds' do
    let!(:mtf_gender) { create(:gender, name: 'MTF') }
    let!(:ftm_gender) { create(:gender, name: 'FTM') }
    let!(:mtf_pin) { create(:pin, procedure: create(:procedure, gender: 'MTF')) }
    let!(:ftm_pin) { create(:pin, procedure: create(:procedure, gender: 'FTM')) }

    it 'shows only matching submissions in the For You feed' do
      user = create(:user, gender: mtf_gender)

      presenter = PinPresenter.new(current_user: user, feed: 'for_you')

      expect(presenter.pins).to include(mtf_pin)
      expect(presenter.pins).not_to include(ftm_pin)
      expect(presenter.showing_for_you?).to eq(true)
    end

    it 'keeps Recent as the default feed for users with a personalized option' do
      user = create(:user, gender: mtf_gender)

      presenter = PinPresenter.new(current_user: user)

      expect(presenter.pins).to include(mtf_pin, ftm_pin)
      expect(presenter.show_feed_navigation?).to eq(true)
      expect(presenter.showing_for_you?).to eq(false)
    end

    it 'uses Recent when the selected feed is unavailable for the user' do
      user = create(:user, gender: create(:gender, name: 'GenderQueer'))

      presenter = PinPresenter.new(current_user: user, feed: 'for_you')

      expect(presenter.pins).to include(mtf_pin, ftm_pin)
      expect(presenter.show_feed_navigation?).to eq(false)
      expect(presenter.showing_for_you?).to eq(false)
    end
  end

  it 'falls back to recent pins when search is unavailable' do
    allow(Pin).to receive(:search).and_raise(Faraday::ConnectionFailed.new("down"))

    presenter = PinPresenter.new(query: "breast")

    expect(presenter.pins).to eq(pins.to_a.reverse)
  end

  it 'falls back to recent pins when search pagination fails' do
    search_results = double("search_results")
    paginated_results = double("paginated_results")
    records = double("records")

    allow(search_results).to receive(:paginate).and_return(paginated_results)
    allow(paginated_results).to receive(:records).and_return(records)
    allow(records).to receive(:to_a).and_raise(Faraday::ConnectionFailed.new("down"))
    allow(Pin).to receive(:search).and_return(search_results)

    presenter = PinPresenter.new(query: "breast")

    expect(presenter.pins).to eq(pins.to_a.reverse)
  end

  it 'keeps successful search results paginated' do
    search_results = double("search_results")
    paginated_results = double("paginated_results")
    records = double("records", total_pages: 1)

    allow(search_results).to receive(:paginate).and_return(paginated_results)
    allow(paginated_results).to receive(:records).and_return(records)
    allow(records).to receive(:to_a).and_return([])
    allow(Pin).to receive(:search).and_return(search_results)

    presenter = PinPresenter.new(query: "breast")

    expect(presenter.pins).to eq(records)
    expect(presenter.pins.total_pages).to eq(1)
  end

  describe "filtering results" do
    let!(:surgeon) { create(:surgeon) }
    let!(:procedure) { create(:procedure) }
    let(:user_id) { pins.last.user_id }

    it 'returns pins scoped by surgeon' do
      pins.last.update_attributes!(surgeon_id: surgeon.id)
      presenter = PinPresenter.new({surgeon: surgeon.id})
      expect(presenter.pins.last).to eq(pins.last)
    end

    it 'returns pins scoped by procedure' do
      pins.last.update_attributes!(procedure_id: procedure.id)
      presenter = PinPresenter.new({procedure: procedure.id})

      expect(presenter.pins.last).to eq(pins.last)
    end

    it 'returns pins scoped by user' do
      presenter = PinPresenter.new({user: user_id})

      expect(presenter.pins.last).to eq(pins.last)
    end

    skip 'performance tests' do
      it 'needs to perform user filtering quickly' do
        expect { PinPresenter.new({user: user_id}) }.to perform_under(0.50).and_sample(10)
      end
      it 'needs to perform surgeon filtering quickly' do
        expect { PinPresenter.new({surgeon: surgeon.id}) }.to perform_under(0.50).and_sample(10)
      end
      it 'needs to perform procedure filtering quickly' do
        expect { PinPresenter.new({procedure: procedure.id}) }.to perform_under(0.50).and_sample(10)
      end
    end
  end

  describe '#has_keywords?' do
    it 'checks scope content' do
      expect(PinPresenter.new({scope: nil}).send(:has_keywords?)).to eq(false)
    end
  end
end
