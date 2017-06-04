class ArtisticResultCalculator2017
  # describes whether the given competitor has any results associated
  def competitor_has_result?(competitor)
    competitor.scores.any?
  end

  # returns the result to be displayed for this competitor
  def competitor_result(_competitor)
    nil
  end

  # returns the result for this competitor
  def competitor_comparable_result(competitor)
    if competitor.has_result?
      total_points(competitor)
    else
      0
    end
  end

  def competitor_tie_break_comparable_result(competitor)
    jt = JudgeType.find_by(name: "Technical", event_class: competitor.competition.event_class) # TODO: this should be properly identified
    total_points_for_judge_type(competitor, jt)
  end

  def eager_load_results_relations(competitors)
    competitors.includes(
      scores: [judge: :judge_type]
    )
  end

  # Calculate the total number of points for a given competitor
  # judge_type: if specified, limit the results to a given judge_type.
  # NOTE: This function takes into account the "removed scores" by chief judge (eliminates them)
  #
  # return a numeric
  def total_points(competitor)
    total = 0
    competitor.competition.judge_types.uniq.each do |jt|
      total += total_points_for_judge_type(competitor, jt)
    end
    total
  end

  def total_points_for_judge_type(competitor, judge_type)
    scores = competitor.scores.joins(:judge).where(judges: { judge_type_id: judge_type.id }).merge(Judge.active)

    active_scores = scores.map(&:placing_points).compact

    (active_scores.sum / active_scores.count.to_f).round(2)
  end
end
