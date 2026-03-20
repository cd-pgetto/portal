class AddUniqueIndexToPracticeMembers < ActiveRecord::Migration[8.1]
  def change
    add_index :practice_members, [:user_id, :practice_id], unique: true
  end
end
