class ChangeEventDatatypes < ActiveRecord::Migration
  def change
    change_column :ip_tables, :from_ip, :bigint
    change_column :ip_tables, :to_ip, :bigint
  end
end
