class RefactorMediaPaths < ActiveRecord::Migration[8.0]
  def up
    # For Movies
    rename_column :movies, :file_path, :import_file_path
    rename_column :movies, :hls_path, :file_path
    
    # For TV Episodes
    rename_column :tv_episodes, :file_path, :import_file_path
    rename_column :tv_episodes, :hls_path, :file_path
    
    # For Songs
    rename_column :songs, :file_path, :import_file_path
    rename_column :songs, :hls_path, :file_path
    
    # Note: Not backfilling existing paths - the RelativePathStorage concern
    # will handle both absolute and relative paths correctly
  end
  
  def down
    # Reverse the column renames
    rename_column :movies, :file_path, :hls_path
    rename_column :movies, :import_file_path, :file_path
    
    rename_column :tv_episodes, :file_path, :hls_path
    rename_column :tv_episodes, :import_file_path, :file_path
    
    rename_column :songs, :file_path, :hls_path
    rename_column :songs, :import_file_path, :file_path
    
    # Note: We're not converting paths back to absolute since we don't know
    # if the root_path has changed since the migration ran
  end
end

