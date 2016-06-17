class RecalculateAvgsQuery
  def self.for(type, id)
    relevant_pins = Pin.where("#{type.to_s.tableize.singularize}_id = #{id}")
    thing_of_type = type.find(id)

    return false if relevant_pins.empty?
    new_avg_sat = relevant_pins.pluck(:satisfaction).reduce(0, :+) / relevant_pins.count

    thing_of_type.avg_satisfaction = new_avg_sat
    new_avg_sen = relevant_pins.pluck(:sensation).reduce(0, :+) / relevant_pins.count
    thing_of_type.avg_sensation = new_avg_sen

    thing_of_type.save!
  end
end
