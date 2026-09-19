require 'rails_helper'

describe ApplicationHelper do
  describe '#display_complication_rate' do
    it 'shows less than one percent for a nonzero rounded-down rate' do
      expect(helper.display_complication_rate(rate: 0, count: 1)).to eq('<1%')
    end

    it 'keeps a true zero at zero percent' do
      expect(helper.display_complication_rate(rate: 0, count: 0)).to eq('0%')
    end

    it 'keeps ordinary percentages unchanged' do
      expect(helper.display_complication_rate(rate: 67, count: 2)).to eq('67%')
    end
  end
end
