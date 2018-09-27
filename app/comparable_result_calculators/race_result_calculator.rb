class RaceResultCalculator
  # describes whether the given competitor has any results associated
  def competitor_has_result?(competitor)
    competitor.finish_time_results.any?
  end

  # returns the result for this competitor
  def competitor_result(competitor)
    if competitor.has_result? && !competitor.disqualified?
      TimeResultPresenter.from_thousands(competitor.best_time_in_thousands, data_entry_format: competitor.competition.data_entry_format).full_time
    end
  end

  # returns the result for this competitor
  def competitor_comparable_result(competitor, with_ineligible: nil) # rubocop:disable Lint/UnusedMethodArgument
    if competitor.has_result? && !competitor.disqualified?
      competitor.best_time_in_thousands
    else
      0
    end
  end

  def competitor_tie_break_comparable_result(_competitor)
    nil
  end

  def eager_load_results_relations(competitors)
    competitors.includes(
      :start_time_results,
      :finish_time_results
    )
  end
end
