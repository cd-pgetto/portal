class CreateDentalModels < ActiveRecord::Migration[8.1]
  def change
    create_table :dental_models, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.belongs_to :patient, null: false, foreign_key: true, type: :uuid
      t.string :model_type, null: false
      t.string :name, null: false

      t.timestamps
    end
  end
end
