class CreateCredentials < ActiveRecord::Migration[8.1]
  def change
    create_table :credentials do |t|
      t.belongs_to :organization, null: false, foreign_key: true
      t.belongs_to :identity_provider, null: false, foreign_key: true

      t.timestamps
    end
    add_index :credentials, [:organization_id, :identity_provider_id], unique: true
  end
end
