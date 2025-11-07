class RenameHlsFieldsToStreamFields < ActiveRecord::Migration[8.0]
  def change
    # Rename hls_duration to stream_duration
    rename_column :tv_episodes, :hls_duration, :stream_duration
    rename_column :songs, :hls_duration, :stream_duration
    
    # Rename hls_qualities to stream_qualities
    rename_column :tv_episodes, :hls_qualities, :stream_qualities
    rename_column :songs, :hls_qualities, :stream_qualities
    
    # Add missing stream fields to movies (they only had 'duration' which is TMDB metadata)
    add_column :movies, :stream_duration, :integer
    add_column :movies, :stream_qualities, :text
  end
end

