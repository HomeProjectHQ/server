class CreateWatchProgresses < ActiveRecord::Migration[8.0]
  def change
    create_table :watch_progresses do |t|
      t.references :profile, null: false, foreign_key: true
      t.references :watchable, polymorphic: true, null: false
      t.integer :position_seconds, default: 0, null: false
      t.integer :duration_seconds
      t.boolean :completed, default: false, null: false
      t.datetime :last_watched_at
      t.integer :watch_count, default: 0, null: false
      
      t.timestamps
      
      t.index [:profile_id, :watchable_type, :watchable_id], 
        unique: true, 
        name: 'index_watch_progresses_uniqueness'
      t.index [:profile_id, :last_watched_at]
    end
  end
end
