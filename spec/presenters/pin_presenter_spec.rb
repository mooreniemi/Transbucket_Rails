require 'rails_helper'

describe PinPresenter do
  before(:each) do
    Rails.cache.clear
  end

  let!(:pins) { create_list(:pin, 3) }

  it 'returns pins' do
    expect(PinPresenter.new.pins).to eq(pins.to_a.reverse)
  end

  it 'falls back to recent pins when search is unavailable' do
    allow(Pin).to receive(:search).and_raise(Faraday::ConnectionFailed.new("down"))

    presenter = PinPresenter.new(query: "breast")

    expect(presenter.pins).to eq(pins.to_a.reverse)
  end

  it 'falls back to recent pins when search pagination fails' do
    search_results = double("search_results")
    paginated_results = double("paginated_results")

    allow(search_results).to receive(:paginate).and_return(paginated_results)
    allow(paginated_results).to receive(:records).and_raise(Faraday::ConnectionFailed.new("down"))
    allow(Pin).to receive(:search).and_return(search_results)

    presenter = PinPresenter.new(query: "breast")

    expect(presenter.pins).to eq(pins.to_a.reverse)
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
