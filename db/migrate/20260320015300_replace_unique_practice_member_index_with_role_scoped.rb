class ReplaceUniquePracticeMemberIndexWithRoleScoped < ActiveRecord::Migration[8.1]
  def change
    remove_index :practice_members, [:user_id, :practice_id]
    add_index :practice_members, [:user_id, :practice_id, :role], unique: true
  end
end
