class Currency < ActiveRecord::Base
    self.table_name = 'currency'
    self.primary_key = :currency

end
