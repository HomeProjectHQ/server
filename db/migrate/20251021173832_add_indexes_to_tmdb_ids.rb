class AddIndexesToTmdbIds < ActiveRecord::Migration[8.0]
  def change
    add_index :movies, :tmdb_id, unique: true
    add_index :tv_shows, :tmdb_id, unique: true
  end
end
