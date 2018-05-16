class SetCategoryAssociations < ActiveRecord::Migration[4.2]
  class RegistrantChoice < ActiveRecord::Base
    belongs_to :event_category
  end
  class EventCategory < ActiveRecord::Base
    belongs_to :event_choice
  end
  class EventChoice < ActiveRecord::Base
    has_many :registrant_choices
  end

  def up
    EventChoice.reset_column_information
    RegistrantChoice.reset_column_information
    EventChoice.where(cell_type: "category").each do |ec|
      ec.registrant_choices.each do |reg_choice|
        next if reg_choice.value == ""
        reg_choice.event_category = EventCategory.find_by(name: reg_choice.value, event_id: ec.event_id)
        reg_choice.save!
      end
    end
  end

  def down; end
end
