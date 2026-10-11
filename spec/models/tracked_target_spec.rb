require 'spec_helper'
require_relative '../../app/models/tracked_target'

describe TrackedTarget do
  it 'gives every target a distinct, stable positive id' do
    ids = TrackedTarget::TARGETS.values

    expect(ids.uniq.size).to eq(ids.size)
    expect(ids).to all(be > 0)
    # Recorded events refer to these ids, so they must never move.
    expect(TrackedTarget.id_for(:news)).to eq(1)
    expect(TrackedTarget.id_for('about')).to eq(2)
  end

  it 'only accepts known ids' do
    expect(TrackedTarget.valid_id?(TrackedTarget.id_for(:discord))).to be(true)
    expect(TrackedTarget.valid_id?('5')).to be(true)
    expect(TrackedTarget.valid_id?(9_999)).to be(false)
    expect(TrackedTarget.valid_id?(0)).to be(false)
  end

  it 'raises for an unknown target name so a typo cannot ship silently' do
    expect { TrackedTarget.id_for(:nope) }.to raise_error(KeyError)
  end
end
