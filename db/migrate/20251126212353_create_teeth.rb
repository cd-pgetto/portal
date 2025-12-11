class CreateTeeth < ActiveRecord::Migration[8.1]
  def change
    create_enum :side, ["right", "left"], default: "right", null: false
    create_table :teeth, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.belongs_to :jaw, null: false, foreign_key: true, type: :uuid
      t.integer :number, null: false
      t.enum :side, enum_type: :side, null: false

      t.timestamps
    end
  end
end
