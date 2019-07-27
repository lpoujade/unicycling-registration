# == Schema Information
#
# Table name: pages
#
#  id             :integer          not null, primary key
#  slug           :string           not null
#  created_at     :datetime
#  updated_at     :datetime
#  position       :integer
#  parent_page_id :integer
#  visible        :boolean          default(TRUE), not null
#
# Indexes
#
#  index_pages_on_parent_page_id_and_position  (parent_page_id,position)
#  index_pages_on_position                     (position)
#  index_pages_on_slug                         (slug) UNIQUE
#

# Read about factories at https://github.com/thoughtbot/factory_bot

FactoryBot.define do
  factory :page do
    sequence(:slug) { |n| "page-#{n}" }
    title { "Page Title" }
    body { "Page Body" }
    sequence(:position) { |n| n }

    trait :home do
      slug { "home" }
    end
  end
end
