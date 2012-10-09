class AddPathAndIndexes < ActiveRecord::Migration
  def change
    add_column :cdn_https, :path, :string
    add_index :cdn_https, [:happened_at, :ip_address, :full_path, :status], :name => 'by_at_ip_fpath_status'
  end
end
