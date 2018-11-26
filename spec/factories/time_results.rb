# == Schema Information
#
# Table name: time_results
#
#  id                  :integer          not null, primary key
#  competitor_id       :integer
#  minutes             :integer
#  seconds             :integer
#  thousands           :integer
#  created_at          :datetime
#  updated_at          :datetime
#  is_start_time       :boolean          default(FALSE), not null
#  number_of_laps      :integer
#  status              :string           not null
#  comments            :text
#  comments_by         :string
#  number_of_penalties :integer
#  entered_at          :datetime         not null
#  entered_by_id       :integer          not null
#  preliminary         :boolean
#  heat_lane_result_id :integer
#  status_description  :string
#
# Indexes
#
#  index_time_results_on_competitor_id        (competitor_id)
#  index_time_results_on_heat_lane_result_id  (heat_lane_result_id) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :time_result do
    association :competitor, factory: :event_competitor
    association :entered_by, factory: :user
    entered_at { Time.current }
    status { "active" }
    preliminary { false }
    is_start_time { false }
    minutes { 0 }
    seconds { 0 }
    thousands { 0 }
  end
end
