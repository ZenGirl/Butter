class CreateCdnHttps < ActiveRecord::Migration
  def change
    create_table :cdn_https do |t|
      t.string :ip_address
      t.datetime :happened_at
      t.string :verb
      t.string :full_path
      t.string :http_version
      t.integer :status
      t.integer :size
      t.string :referrer
      t.string :user_agent

      t.timestamps
    end
  end
end
