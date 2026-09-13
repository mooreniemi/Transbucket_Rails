require 'rails_helper'

describe Searchable do
  before { Delayed::Job.delete_all }

  it 'queues document deletion by index name and ID after a record is destroyed' do
    pin = create(:pin)
    pin_id = pin.id
    index_name = Pin.index_name
    Delayed::Job.delete_all

    pin.destroy

    job = Delayed::Job.all.find do |candidate|
      payload = candidate.payload_object
      payload.method_name == :delete_document_async_without_delay &&
        payload.object == Pin
    end

    expect(job).to be_present
    expect(job.payload_object.args).to eq([index_name, pin_id])
  end
end
