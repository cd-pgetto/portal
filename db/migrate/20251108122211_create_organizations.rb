class CreateOrganizations < ActiveRecord::Migration[8.1]
  def change
    create_table :organizations do |t|
      t.string :name, null: false
      t.string :subdomain, null: false, index: { unique: true }
      t.boolean :allows_password_auth, default: true, null: false

      t.timestamps
    end
  end
end
