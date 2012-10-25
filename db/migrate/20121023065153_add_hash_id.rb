class AddHashId < ActiveRecord::Migration
  def change
    add_column :cdn_https, :md5_id, :string
    add_index :cdn_https, :md5_id
    add_column :cdn_fcs, :md5_id, :string
    add_index :cdn_fcs, :md5_id
  end
end
