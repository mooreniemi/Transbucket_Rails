require 'spec_helper'

describe PinPresenter do
  let!(:pins) { create_list(:pin, 3) }

  it 'returns pins' do
    expect(PinPresenter.new.all).to eq(pins.to_a.reverse)
  end

  describe "filtering results" do
    let(:surgeon) { build(:surgeon) }
    let(:procedure) { build(:procedure) }
    let(:user_id) { pins.last.user_id }

    it 'returns pins scoped by surgeon' do
      pins.last.update_attributes(surgeon_id: surgeon.id)
      presenter = PinPresenter.new({surgeon: surgeon.id})

      expect(presenter.all.last).to eq(pins.last)
    end

    it 'returns pins scoped by procedure' do
      pins.last.update_attributes(procedure_id: procedure.id)
      presenter = PinPresenter.new({procedure: procedure.id})

      expect(presenter.all.last).to eq(pins.last)
    end

    it 'returns pins scoped by user' do
      presenter = PinPresenter.new({user: user_id})

      expect(presenter.all.last).to eq(pins.last)
    end
  end

  describe '#has_keywords?' do
    it 'checks scope content' do
      expect(PinPresenter.new({scope: nil}).send(:has_keywords?)).to eq(false)
    end
  end
end
