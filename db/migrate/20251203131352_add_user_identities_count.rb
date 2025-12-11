class AddUserIdentitiesCount < ActiveRecord::Migration[8.1]
  def change
    add_column :users, :identities_count, :integer, default: 0, null: false

    reversible do |dir|
      dir.up do
        User.find_each { |user| User.reset_counters(user.id, :identities) }
      end
    end
  end
end
