class RefactorIdentityProviderArchitecture < ActiveRecord::Migration[8.1]
  def up
    # 1. Rename credentials → organization_shared_identity_providers
    rename_table :credentials, :organization_shared_identity_providers

    # 2. Add organization_id FK to identity_providers for dedicated providers
    add_column :identity_providers, :organization_id, :uuid
    add_foreign_key :identity_providers, :organizations

    # 3. Migrate existing dedicated provider credentials → organization_id
    execute <<~SQL
      UPDATE identity_providers ip
      SET organization_id = osip.organization_id
      FROM organization_shared_identity_providers osip
      WHERE osip.identity_provider_id = ip.id
        AND ip.availability = 'dedicated'
    SQL

    # 4. Remove dedicated provider entries from the shared join table
    execute <<~SQL
      DELETE FROM organization_shared_identity_providers
      WHERE identity_provider_id IN (
        SELECT id FROM identity_providers WHERE availability = 'dedicated'
      )
    SQL

    # 5. Partial unique index: one dedicated provider per organization
    add_index :identity_providers, :organization_id,
      unique: true,
      where: "organization_id IS NOT NULL",
      name: "index_identity_providers_on_organization_id"

    # 6. Replace availability-based strategy uniqueness index with organization_id-based one
    remove_index :identity_providers, name: "index_identity_providers_on_strategy"
    add_index :identity_providers, :strategy,
      unique: true,
      where: "organization_id IS NULL",
      name: "index_identity_providers_on_strategy"

    # 7. Drop availability column and enum type
    remove_column :identity_providers, :availability
    execute "DROP TYPE availability"
  end

  def down
    # Restore availability enum and column
    execute "CREATE TYPE availability AS ENUM ('shared', 'dedicated')"
    add_column :identity_providers, :availability, :enum, enum_type: :availability, null: false, default: "shared"
    execute "UPDATE identity_providers SET availability = 'dedicated' WHERE organization_id IS NOT NULL"

    # Restore strategy uniqueness index
    remove_index :identity_providers, name: "index_identity_providers_on_strategy"
    add_index :identity_providers, :strategy,
      unique: true,
      where: "availability = 'shared'",
      name: "index_identity_providers_on_strategy"

    # Restore dedicated provider entries in the join table
    execute <<~SQL
      INSERT INTO organization_shared_identity_providers (id, organization_id, identity_provider_id, created_at, updated_at)
      SELECT gen_random_uuid(), organization_id, id, NOW(), NOW()
      FROM identity_providers
      WHERE organization_id IS NOT NULL
    SQL

    # Remove organization_id from identity_providers
    remove_index :identity_providers, name: "index_identity_providers_on_organization_id"
    remove_foreign_key :identity_providers, :organizations
    remove_column :identity_providers, :organization_id

    # Rename table back
    rename_table :organization_shared_identity_providers, :credentials
  end
end
