class InitiallyRegistrationIsClosed < ActiveRecord::Migration[4.2]
  def up
    add_column :event_configurations, :under_construction, :boolean
    # Set existing EventConfigurations to have under_construction false
    change_column_null :event_configurations, :under_construction, false, false
    change_column_default :event_configurations, :under_construction, true
  end

  def down
    raise ActiveRecord::IrreversibleMigration
  end
end
