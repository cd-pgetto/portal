class AddInternalToOrganizations < ActiveRecord::Migration[8.1]
  def change
    add_column :organizations, :internal, :boolean, default: false, null: false
    add_index :organizations, :internal, unique: true, where: "internal = true"
  end
end
