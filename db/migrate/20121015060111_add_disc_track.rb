class AddDiscTrack < ActiveRecord::Migration
  def change
    add_column :media_events, :disc, :integer
    add_column :media_events, :track, :integer
    add_index :media_events, :disc
    add_index :media_events, :track
  end
end
