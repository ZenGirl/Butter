class AddFcsIndexes < ActiveRecord::Migration
  def change
    add_index :cdn_fcs, :mode
    add_index :cdn_fcs, :happened_at
    add_index :cdn_fcs, :path
    add_index :cdn_fcs, :http_status
    add_index :cdn_fcs, :ip_address
    add_index :cdn_fcs, [:happened_at, :ip_address, :path, :http_status], :name => 'by_most'
  end
end
