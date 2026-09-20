require 'rails_helper'

describe 'shared/_compare_events', type: :view do
  before { allow(view).to receive(:content_events_path).and_return('/en/content_events') }

  def markers_for(locals)
    render partial: 'shared/compare_events', locals: locals
    Nokogiri::HTML(rendered).css('[data-content-event]')
  end

  it 'renders one view marker per compared entity, positioned 1 and 2' do
    first = create(:surgeon)
    second = create(:surgeon)

    markers = markers_for(content_type: 'Surgeon', kind: 'surgeons', first: first, second: second, scoped: false)

    expect(markers.length).to eq(2)
    expect(markers.map { |marker| marker['data-content-id'] }).to eq([first.id.to_s, second.id.to_s])
    expect(markers.map { |marker| marker['data-event-type'] }.uniq).to eq(['view'])
    expect(markers.map { |marker| JSON.parse(marker['data-event-context']) }).to eq([
      { 'surface' => 'compare', 'list_mode' => 'surgeons', 'filter_signature' => '', 'rank' => '1' },
      { 'surface' => 'compare', 'list_mode' => 'surgeons', 'filter_signature' => '', 'rank' => '2' }
    ])
  end

  it 'marks a comparison scoped to a shared surgeon or procedure' do
    markers = markers_for(content_type: 'Procedure', kind: 'procedures', first: create(:procedure), second: create(:procedure), scoped: true)

    expect(JSON.parse(markers.first['data-event-context'])['filter_signature']).to eq('scope')
  end
end
