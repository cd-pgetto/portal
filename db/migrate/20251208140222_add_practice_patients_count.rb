class AddPracticePatientsCount < ActiveRecord::Migration[8.1]
  def change
    add_column :practices, :patients_count, :integer, default: 0, null: false

    reversible do |dir|
      dir.up { Practice.find_each { |practice| Practice.reset_counters(practice.id, :patients) } }
    end
  end
end
