# == Schema Information
#
# Table name: external_results
#
#  id            :integer          not null, primary key
#  competitor_id :integer
#  details       :string
#  points        :decimal(6, 3)    not null
#  created_at    :datetime
#  updated_at    :datetime
#  entered_by_id :integer          not null
#  entered_at    :datetime         not null
#  status        :string           not null
#  preliminary   :boolean          not null
#
# Indexes
#
#  index_external_results_on_competitor_id  (competitor_id) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :external_result do
    association :competitor, factory: :event_competitor
    association :entered_by, factory: :user
    entered_at { Time.current }
    details { "MyString" }
    points { 1 }
    status { "active" }
    preliminary { false }

    trait :preliminary do
      preliminary { true }
    end
  end
end
