class RenameIdentityProviderTypes < ActiveRecord::Migration[8.1]
  def up
    execute <<~SQL
      UPDATE identity_providers SET type = 'IdentityProvider::Shared' WHERE type IS NULL OR type = 'IdentityProvider';
      UPDATE identity_providers SET type = 'IdentityProvider::Dedicated' WHERE type = 'DedicatedIdentityProvider';
      UPDATE identity_providers SET type = 'IdentityProvider::Okta' WHERE type = 'OktaIdentityProvider';
    SQL
  end

  def down
    execute <<~SQL
      UPDATE identity_providers SET type = NULL WHERE type = 'IdentityProvider::Shared';
      UPDATE identity_providers SET type = 'DedicatedIdentityProvider' WHERE type = 'IdentityProvider::Dedicated';
      UPDATE identity_providers SET type = 'OktaIdentityProvider' WHERE type = 'IdentityProvider::Okta';
    SQL
  end
end
