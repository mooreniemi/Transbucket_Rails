module Stats
  def recalculate_avgs
    RecalculateAvgsQuery.for(self.class, self.id)
  end
end
