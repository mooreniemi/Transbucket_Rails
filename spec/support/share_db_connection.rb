class ActiveRecord::Base
  mattr_accessor :shared_connection
  @@shared_connection = nil

  def self.connection
    @@shared_connection || ConnectionPool::Wrapper.new(:size => 1) { retrieve_connection }
  end
end

ActiveRecord::Base.shared_connection = ActiveRecord::Base.connection

# hack a mutex in the query execution so that we don't
# get competing queries that can timeout and not get cleaned up
module MutexLockedQuerying
  @@semaphore = Mutex.new

  def async_exec(*)
    @@semaphore.synchronize { super }
  end
end

PG::Connection.prepend(MutexLockedQuerying)
