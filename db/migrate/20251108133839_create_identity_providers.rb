class CreateIdentityProviders < ActiveRecord::Migration[8.1]
  def change
    create_enum :availability, %w[shared dedicated], default: "shared", null: false

    create_table :identity_providers, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.string :name, null: false
      t.string :icon_url, null: false
      t.string :strategy, null: false
      t.enum :availability, enum_type: :availability, null: false, default: "shared"
      t.string :client_id, null: false
      t.string :client_secret, null: false

      t.timestamps
    end

    add_index :identity_providers, [:strategy, :client_id], unique: true
    add_index :identity_providers, :strategy, where: "availability = 'shared'", unique: true
  end
end
