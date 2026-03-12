class EncryptDedicatedIdpCredentials < ActiveRecord::Migration[8.1]
  def up
    # Change to text and drop null constraint first, then null out shared provider credentials
    change_column :identity_providers, :client_id, :text, null: true
    change_column :identity_providers, :client_secret, :text, null: true

    # Credentials for shared providers are read from the credentials file at startup — not stored in DB
    execute "UPDATE identity_providers SET client_id = NULL, client_secret = NULL WHERE organization_id IS NULL"

    # Drop the strategy+client_id uniqueness index — not meaningful with nullable encrypted values
    remove_index :identity_providers, name: "index_identity_providers_on_strategy_and_client_id"
  end

  def down
    # Fill in a placeholder before restoring the not-null constraint
    execute "UPDATE identity_providers SET client_id = '', client_secret = '' WHERE organization_id IS NULL"

    change_column :identity_providers, :client_id, :string, null: false, default: ""
    change_column :identity_providers, :client_secret, :string, null: false, default: ""

    add_index :identity_providers, [:strategy, :client_id], unique: true,
      name: "index_identity_providers_on_strategy_and_client_id"
  end
end
