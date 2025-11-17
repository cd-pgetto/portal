class RenameOrgAllowsPasswordAuth < ActiveRecord::Migration[8.1]
  def change
    rename_column :organizations, :allows_password_auth, :password_auth_allowed
  end
end
