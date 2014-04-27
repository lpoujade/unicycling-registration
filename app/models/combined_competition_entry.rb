class CombinedCompetitionEntry < ActiveRecord::Base

  belongs_to :combined_competition
  belongs_to :competition

  validates :combined_competition_id, :abbreviation, presence: true
  validates :competition_id, presence: true
  validates :points_1, :points_2, :points_3, :points_4, :points_5, presence: true
  validates :points_6, :points_7, :points_8, :points_9, :points_10, presence: true

  validates :tie_breaker, inclusion: { in: [true, false] }

  def to_s
    abbreviation + (tie_breaker ? "*" : "")
  end

  def competitors
    @males = competition.competitors.select{ |comp| comp.is_top?("Male") }
    @females = competition.competitors.select{ |comp| comp.is_top?("Female") }
    [@males, @females]
  end
end
