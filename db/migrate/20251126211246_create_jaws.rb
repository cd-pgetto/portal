class CreateJaws < ActiveRecord::Migration[8.1]
  def change
    create_enum :jaw_type, ["maxilla", "mandible"], default: "maxilla", null: false
    create_table :jaws, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.belongs_to :dental_model, null: false, foreign_key: true, type: :uuid
      t.enum :jaw_type, enum_type: :jaw_type, null: false, default: "maxilla"

      t.timestamps
    end

    add_index :jaws, [:dental_model_id, :jaw_type], unique: true
  end
end
