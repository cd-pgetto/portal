class CreatePatients < ActiveRecord::Migration[8.1]
  def change
    create_table :patients, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.belongs_to :practice, null: false, foreign_key: true, type: :uuid
      t.string :patient_number, null: false
      t.string :chart_number, null: false

      t.timestamps
    end

    add_index :patients, [:practice_id, :patient_number], unique: true
  end
end
