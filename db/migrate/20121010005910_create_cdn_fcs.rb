class CreateCdnFcs < ActiveRecord::Migration
  def change
    create_table :cdn_fcs do |t|
      t.string :mode
      t.datetime :happened_at
      t.string :path
      t.integer :http_status
      t.string :ip_address

      t.timestamps
    end
  end
end
