class CreateSettings < ActiveRecord::Migration[8.0]
  def change
    create_table :settings do |t|
      # Singleton guard - ensures only one row can exist
      t.integer :singleton_guard, null: false, default: 0
      
      # Storage root paths
      t.string :root_path, default: "/Users/Shared/nfs/media/Home", null: false
      
      # Transcode settings
      t.integer :max_transcode_quality, default: 1080
      t.string :transcode_codec, default: "hevc_videotoolbox"
      
      # Scan settings
      t.boolean :enable_auto_scan, default: true
      t.integer :scan_interval_minutes, default: 60
      
      # Feature flags
      t.boolean :enable_transcoding, default: true
      t.boolean :enable_artwork_downloads, default: true

      t.timestamps
    end
    
    # Unique index on singleton_guard ensures only one row
    add_index :settings, :singleton_guard, unique: true
  end
end

