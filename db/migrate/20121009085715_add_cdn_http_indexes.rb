class AddCdnHttpIndexes < ActiveRecord::Migration
  def change
    add_index :cdn_https, :happened_at
    add_index :cdn_https, :ip_address
  end
end
