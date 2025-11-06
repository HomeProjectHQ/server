class RenameUsersToProfiles < ActiveRecord::Migration[8.0]
  def change
    # Rename main users table to profiles
    rename_table :users, :profiles
    
    # Rename join tables
    rename_table :user_movies, :profile_movies
    rename_table :user_tv_shows, :profile_tv_shows
    rename_table :user_songs, :profile_songs
    
    # Rename foreign key columns in join tables
    rename_column :profile_movies, :user_id, :profile_id
    rename_column :profile_tv_shows, :user_id, :profile_id
    rename_column :profile_songs, :user_id, :profile_id
    
    # Note: Indexes are automatically renamed when tables are renamed
  end
end
