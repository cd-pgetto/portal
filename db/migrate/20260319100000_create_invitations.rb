class CreateInvitations < ActiveRecord::Migration[8.1]
  def change
    create_table :invitations, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.references :practice, null: false, foreign_key: true, type: :uuid
      t.references :invited_by, null: false, foreign_key: {to_table: :users}, type: :uuid
      t.string :email, null: false
      t.enum :role, enum_type: "practice_role", null: false, default: "member"
      t.datetime :accepted_at

      t.timestamps
    end

    add_index :invitations, [:practice_id, :email], unique: true,
      where: "accepted_at IS NULL", name: "index_invitations_on_practice_id_and_email_pending"
  end
end
