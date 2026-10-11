require 'rails_helper'

describe Searchable do
  before { Delayed::Job.delete_all }

  it 'queues indexing with an index name and ID instead of a serialized record' do
    pin = create(:pin)
    job = Delayed::Job.all.find do |candidate|
      payload = candidate.payload_object
      payload.method_name == :index_document_async_without_delay &&
        payload.object == Pin
    end

    expect(job).to be_present
    expect(job.payload_object.args).to eq([Pin.index_name, pin.id])
    expect(job.payload_object.args).not_to include(pin)
  end

  it 'reloads the record when the primitive indexing job runs' do
    pin = create(:pin)
    job = Delayed::Job.all.find do |candidate|
      candidate.payload_object.method_name == :index_document_async_without_delay
    end
    elasticsearch = double('elasticsearch')

    allow(Pin).to receive(:find_by).with(id: pin.id).and_return(pin)
    allow(pin).to receive(:__elasticsearch__).and_return(elasticsearch)
    expect(elasticsearch).to receive(:index_document)

    job.payload_object.perform
  end

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

  it 'still runs an indexing job queued by the Rails 4 release' do
    pin = create(:pin)
    Delayed::Job.delete_all
    # The handler shape delayed_job wrote on Rails 4: the whole record,
    # reloaded by ID, with the generated instance method.
    Delayed::Job.create!(handler: <<~YAML)
      --- !ruby/object:Delayed::PerformableMethod
      object: !ruby/ActiveRecord:Pin
        attributes:
          id: #{pin.id}
          description: legacy
      method_name: :index_document_async_without_delay
      args: []
    YAML
    elasticsearch = double('elasticsearch')
    allow_any_instance_of(Pin).to receive(:__elasticsearch__).and_return(elasticsearch)
    expect(elasticsearch).to receive(:index_document)

    successes, failures = Delayed::Worker.new.work_off

    expect([successes, failures]).to eq([1, 0])
    expect(Delayed::Job.count).to eq(0)
  end
end
