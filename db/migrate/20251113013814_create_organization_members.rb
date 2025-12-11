class CreateOrganizationMembers < ActiveRecord::Migration[8.1]
  def change
    create_enum :organization_role, ["owner", "admin", "member", "inactive"]
    create_table :organization_members, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.belongs_to :organization, null: false, foreign_key: true, type: :uuid
      t.belongs_to :user, null: false, foreign_key: true, type: :uuid
      t.enum :role, enum_type: :organization_role, null: false, default: "member"

      t.timestamps
    end
  end
end
