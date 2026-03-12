class MigrateOktaIdentityProvidersToSti < ActiveRecord::Migration[8.1]
  def up
    add_column :identity_providers, :type, :string
    add_column :identity_providers, :okta_domain, :string
    add_index :identity_providers, :type

    drop_table :okta_identity_providers
  end

  def down
    create_table :okta_identity_providers, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.belongs_to :identity_provider, null: false, foreign_key: true, type: :uuid
      t.string :okta_domain, null: false
      t.timestamps
    end

    remove_index :identity_providers, :type
    remove_column :identity_providers, :okta_domain
    remove_column :identity_providers, :type
  end
end
