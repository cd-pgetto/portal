class CreateOktaIdentityProviders < ActiveRecord::Migration[8.1]
  def change
    create_table :okta_identity_providers, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.belongs_to :identity_provider, null: false, foreign_key: true, type: :uuid
      t.string :okta_domain, null: false

      t.timestamps
    end
  end
end
