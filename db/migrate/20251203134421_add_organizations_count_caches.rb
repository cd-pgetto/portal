class AddOrganizationsCountCaches < ActiveRecord::Migration[8.1]
  def change
    add_column :organizations, :practices_count, :integer, default: 0, null: false
    add_column :organizations, :email_domains_count, :integer, default: 0, null: false

    reversible do |dir|
      dir.up do
        Organization.find_each { |org| Organization.reset_counters(org.id, :practices) }
        Organization.find_each { |org| Organization.reset_counters(org.id, :email_domains) }
      end
    end
  end
end
