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
# Indexes
#
#  index_results_on_competitor_id_and_result_type  (competitor_id,result_type) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :result do
    association :competitor, factory: :event_competitor # FactoryBot
    place { 1 }
    result_type { "AgeGroup" }

    trait :overall do
      result_type { "Overall" }
    end
  end
end
