class MultiLineChart::Index
  def self.get
    users = MultiLineChart::User.get
    contributions = MultiLineChart::Contribution.get

    xAxis = contributions.map(&:first)
    u_trend = users.inject([]){ |acc, value| acc << acc.last.to_i + value[1].to_i }
    c_trend = contributions.inject([]){ |acc, value| acc << acc.last.to_i + value[1].to_i }

    [u_trend, c_trend, xAxis]
  end
end
