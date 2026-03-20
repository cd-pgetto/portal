class AddActiveToPracticeMembersAndRemoveInactiveRole < ActiveRecord::Migration[8.1]
  def up
    add_column :practice_members, :active, :boolean, default: true, null: false

    # Migrate existing inactive role rows to member + deactivated
    execute "UPDATE practice_members SET role = 'member', active = false WHERE role = 'inactive'"

    # Both practice_members and invitations use practice_role; cast both to text first
    execute "ALTER TABLE practice_members ALTER COLUMN role DROP DEFAULT"
    execute "ALTER TABLE practice_members ALTER COLUMN role TYPE text"
    execute "ALTER TABLE invitations ALTER COLUMN role DROP DEFAULT"
    execute "ALTER TABLE invitations ALTER COLUMN role TYPE text"

    execute "DROP TYPE practice_role"
    execute "CREATE TYPE practice_role AS ENUM ('owner', 'admin', 'member', 'dentist', 'hygienist', 'assistant')"

    execute "ALTER TABLE practice_members ALTER COLUMN role TYPE practice_role USING role::practice_role"
    execute "ALTER TABLE practice_members ALTER COLUMN role SET DEFAULT 'member'"
    execute "ALTER TABLE invitations ALTER COLUMN role TYPE practice_role USING role::practice_role"
    execute "ALTER TABLE invitations ALTER COLUMN role SET DEFAULT 'member'"
  end

  def down
    execute "ALTER TABLE practice_members ALTER COLUMN role DROP DEFAULT"
    execute "ALTER TABLE practice_members ALTER COLUMN role TYPE text"
    execute "ALTER TABLE invitations ALTER COLUMN role DROP DEFAULT"
    execute "ALTER TABLE invitations ALTER COLUMN role TYPE text"

    execute "DROP TYPE practice_role"
    execute "CREATE TYPE practice_role AS ENUM ('owner', 'admin', 'member', 'dentist', 'hygienist', 'assistant', 'inactive')"

    execute "ALTER TABLE practice_members ALTER COLUMN role TYPE practice_role USING role::practice_role"
    execute "ALTER TABLE practice_members ALTER COLUMN role SET DEFAULT 'member'"
    execute "ALTER TABLE invitations ALTER COLUMN role TYPE practice_role USING role::practice_role"
    execute "ALTER TABLE invitations ALTER COLUMN role SET DEFAULT 'member'"

    remove_column :practice_members, :active
  end
end
