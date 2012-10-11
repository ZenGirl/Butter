class ChangeEventsColumns < ActiveRecord::Migration
  def change
    rename_column :ip_tables, :from, :from_ip
    rename_column :ip_tables, :to, :to_ip
  end
end
