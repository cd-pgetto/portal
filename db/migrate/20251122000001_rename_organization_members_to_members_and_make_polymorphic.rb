class RenameOrganizationMembersToMembersAndMakePolymorphic < ActiveRecord::Migration[8.1]
  def change
    rename_table :organization_members, :members

    # Remove the old foreign key
    remove_foreign_key :members, :organizations
    remove_index :members, :organization_id

    # Rename organization_id to business_unit_id and add business_unit_type
    rename_column :members, :organization_id, :business_unit_id
    add_column :members, :business_unit_type, :string, null: false, default: "Organization"

    # Remove the default after setting all values
    change_column :members, :business_unit_type, :string, null: false

    # Create the polymorphic index
    add_index :members, [:business_unit_id, :business_unit_type]
    add_index :members, :user_id, if_not_exists: true

    # Add back the foreign key constraint for organizations
    add_foreign_key :members, :organizations, column: :business_unit_id, primary_key: :id, constraints: false
  end
end
