class CreateEmailDomains < ActiveRecord::Migration[8.1]
  def change
    create_table :email_domains, id: :uuid do |t|
      t.belongs_to :organization, null: false, foreign_key: true, type: :uuid
      t.string :domain_name, null: false

      t.timestamps
    end
    add_index :email_domains, :domain_name, unique: true
  end
end
