class CreateEventsTable < ActiveRecord::Migration
  def change
    create_table :media_events do |t|
      t.string :event
      t.string :source
      t.string :media_id
      t.string :label
      t.string :label_id
      t.integer :user_id
      t.string :country
      t.string :upc
      t.string :isrc
      t.datetime :happened_at
      t.string :album
      t.string :artist
      t.string :title
      t.string :duration
      t.boolean :is_sme
      t.boolean :is_royalty_bearing

      t.timestamps
    end
    add_index :media_events, :event
    add_index :media_events, :source
    add_index :media_events, :media_id
    add_index :media_events, :label
    add_index :media_events, :country
    add_index :media_events, :upc
    add_index :media_events, :happened_at
  end
end
