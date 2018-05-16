class CreateHeatTimesTable < ActiveRecord::Migration[4.2]
  def change
    create_table :heat_times do |t|
      t.references :competition
      t.integer :heat
      t.integer :minutes
      t.integer :seconds
      t.timestamps
    end
  end
end
