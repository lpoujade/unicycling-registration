class AllowMultipleJudgesWithSameName < ActiveRecord::Migration[4.2]
  def up
    remove_index :judge_types, :name
    add_index :judge_types, %i[name event_class], unique: true
  end

  def down
    remove_index :judge_types, %i[name event_class]
    add_index :judge_types, :name, unique: true
  end
end
