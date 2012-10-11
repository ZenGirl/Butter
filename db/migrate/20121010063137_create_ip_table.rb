class CreateIpTable < ActiveRecord::Migration
  def change
    create_table :ip_tables do |t|
      t.integer :from
      t.integer :to
      t.string :registry
      t.integer :assigned
      t.string :country
      t.string :country3
      t.string :country_name

      t.timestamps
    end
    add_index :ip_tables, :from
    add_index :ip_tables, :to
    add_index :ip_tables, :country
  end
end
