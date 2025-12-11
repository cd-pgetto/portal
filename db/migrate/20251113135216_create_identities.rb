class CreateIdentities < ActiveRecord::Migration[8.1]
  def change
    create_table :identities, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.belongs_to :user, null: false, foreign_key: true, type: :uuid
      t.belongs_to :identity_provider, null: false, foreign_key: true, type: :uuid
      t.string :provider_user_id, null: false

      t.timestamps
    end
  end
end
