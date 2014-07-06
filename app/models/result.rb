# == Schema Information
#
# Table name: results
#
#  id             :integer          not null, primary key
#  competitor_id  :integer
#  result_type    :string(255)
#  result_subtype :integer
#  place          :integer
#  status         :string(255)
#  created_at     :datetime
#  updated_at     :datetime
#

class Result < ActiveRecord::Base
  #include CachedModel

  belongs_to :competitor, dependent: :destroy, inverse_of: :results

  validates :competitor, :place, :result_type, presence: true
  validates :competitor, uniqueness: { scope: [:result_type] }

  def self.age_group
    where(result_type: "AgeGroup")
  end

  def self.overall
    where(result_type: "Overall")
  end

  def self.update_last_data_update_time(competition, datetime = DateTime.now)
    Rails.cache.write("/competition/#{competition.id}/last_data_update_time", datetime)
  end

  def self.update_last_calc_places_time(competition, datetime = DateTime.now)
    Rails.cache.write("/competition/#{competition.id}/last_calc_places_time", datetime)
  end

  def self.last_data_update_time(competition)
    Rails.cache.fetch("/competition/#{competition.id}/last_data_update_time")
  end

  def self.last_calc_places_time(competition)
    Rails.cache.fetch("/competition/#{competition.id}/last_calc_places_time")
  end

  def self.competition_calc_needed?(competition)
    ldut = last_data_update_time(competition)
    lcpt = last_calc_places_time(competition)
    ldut.nil? || lcpt.nil? || (ldut > lcpt)
  end

  def to_s
    return "DQ" if status == "DQ"
    if place == 0 || place.nil?
      "Unknown"
    else
      place
    end
  end

  def self.create_new!(competitor, new_place, result_type, result_subtype = nil)
    if new_place == "DQ"
      new_place = 0
      status = "DQ"
    else
      status = nil
    end
    existing_result = Result.where(competitor: competitor, result_type: result_type).first

    if existing_result
      if existing_result.place == new_place
        return
      else
        existing_result.place = new_place
        existing_result.save!
      end
    else
      result = Result.new(competitor: competitor, place: new_place, result_type: result_type, result_subtype: result_subtype, status: status)
      result.save!
    end
  end
end
