RSpec.configure do |config|
  non_transaction_strategy = :deletion

  config.before(:suite) do
    DatabaseCleaner.clean_with(non_transaction_strategy)
  end

  config.before(:each) do
    DatabaseCleaner.strategy = :transaction
  end

  config.before(:each, :js => true) do
    DatabaseCleaner.strategy = non_transaction_strategy
  end

  config.before(:each) do
    DatabaseCleaner.start
  end

  config.after(:each) do
    DatabaseCleaner.clean
  end

end
