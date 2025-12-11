class CreatePracticeMembers < ActiveRecord::Migration[8.1]
  def change
    create_enum :practice_role, ["owner", "admin", "member", "dentist", "hygienist", "assistant", "inactive"]

    create_table :practice_members, id: :uuid, default: -> { "uuidv7()" } do |t|
      t.belongs_to :practice, null: false, foreign_key: true, type: :uuid
      t.belongs_to :user, null: false, foreign_key: true, type: :uuid
      t.enum :role, enum_type: "practice_role", null: false, default: "member"

      t.timestamps
    end
  end
end
