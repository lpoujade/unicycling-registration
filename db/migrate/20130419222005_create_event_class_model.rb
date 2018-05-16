class CreateEventClassModel < ActiveRecord::Migration[4.2]
  def change
    create_table :event_classes do |t|
      t.string :name
      t.timestamps
    end
  end
end
