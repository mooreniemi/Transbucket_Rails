require 'rails_helper'

describe ApplicationHelper do
  describe '#ads_allowed?' do
    before do
      allow(helper).to receive(:controller_path).and_return(controller_path)
      allow(helper).to receive(:action_name).and_return(action_name)
    end

    context 'on a pin submission form' do
      let(:controller_path) { 'pins' }

      %w[new edit create update].each do |form_action|
        context "while rendering #{form_action}" do
          let(:action_name) { form_action }

          it 'disables ads' do
            expect(helper.ads_allowed?).to be(false)
          end
        end
      end
    end

    context 'away from a pin submission form' do
      let(:controller_path) { 'pins' }
      let(:action_name) { 'show' }

      it 'allows ads' do
        expect(helper.ads_allowed?).to be(true)
      end
    end
  end

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
