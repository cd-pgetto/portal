class CreatePractices < ActiveRecord::Migration[8.1]
  def change
    create_table :practices, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.string :name, null: false
      t.belongs_to :organization, null: false, foreign_key: true, type: :uuid

      t.timestamps
    end
  end
end
