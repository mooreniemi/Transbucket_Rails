module ComparisonStatistics
  MINIMUM_RATED_SUBMISSIONS = 30
  SIGNIFICANCE_LEVEL = 0.05

  def self.for(first_data, second_data)
    [:sensation, :satisfaction].each_with_object({}) do |rating, result|
      first_distribution = first_data[:distributions][rating]
      second_distribution = second_data[:distributions][rating]
      first_rated = first_distribution.values.sum
      second_rated = second_distribution.values.sum
      first_good = first_distribution.select { |score, _count| score >= 3 }.values.sum
      second_good = second_distribution.select { |score, _count| score >= 3 }.values.sum
      p_value = fisher_exact_p_value(
        first_good, first_rated - first_good,
        second_good, second_rated - second_good
      )

      result[rating] = {
        first_rated: first_rated,
        second_rated: second_rated,
        p_value: p_value,
        insufficient_data: [first_rated, second_rated].min < MINIMUM_RATED_SUBMISSIONS,
        significant: p_value && p_value < SIGNIFICANCE_LEVEL
      }
    end
  end

  # Exact two-sided p-value for the 2x2 table of good versus other ratings.
  # This avoids relying on a paid or unbundled statistics dependency.
  def self.fisher_exact_p_value(a, b, c, d)
    total = a + b + c + d
    return nil if total.zero?

    row_one = a + b
    column_one = a + c
    minimum = [0, row_one - (total - column_one)].max
    maximum = [row_one, column_one].min
    observed = hypergeometric_probability(a, b, c, d)

    (minimum..maximum).sum do |possible_a|
      possible_b = row_one - possible_a
      possible_c = column_one - possible_a
      possible_d = total - possible_a - possible_b - possible_c
      probability = hypergeometric_probability(possible_a, possible_b, possible_c, possible_d)
      probability <= observed + 1e-12 ? probability : 0.0
    end.round(6)
  end

  def self.hypergeometric_probability(a, b, c, d)
    Math.exp(
      log_combination(a + b, a) +
      log_combination(c + d, c) -
      log_combination(a + b + c + d, a + c)
    )
  end
  private_class_method :hypergeometric_probability

  def self.log_combination(n, k)
    Math.lgamma(n + 1)[0] - Math.lgamma(k + 1)[0] - Math.lgamma(n - k + 1)[0]
  end
  private_class_method :log_combination
end
